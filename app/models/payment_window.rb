class PaymentWindow < ActiveRecord::Base

  belongs_to :project

  has_many :subscription_payments

  has_many :pending_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Pending' or status = 'Open'"
  has_many :completed_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Paid'"
  has_many :defaulted_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Defaulted'"
  has_many :thrown_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Thrown'"
  has_many :reused_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Reused'"

  validates_format_of :paypal_email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :on => :create, :message=>"Invalid email address."

  @@PAYMENT_STATUSES = ["Active", "Successful", "Failed"]

  def open?
    status == "Active"
  end
  
  def amount_payment_collected
    @amount = 0

    completed_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def amount_payment_pending
    @amount = 0

    pending_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def amount_defaulted_payment
    @amount = 0

    defaulted_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def all_payments_collected?
    pending_payments.size == 0 && defaulted_payments.size == 0 && thrown_payments.size == 0 && reused_payments.size == 0
  end

  def total_share_amount
    subscription_payments.sum(:share_amount)
  end

  def share_queue_pending_amount
    project.share_queue_pending.sum(&:amount)
  end

  def share_queue_pending_pmf_fund_amount
    project.share_queue_pending_pmf_fund.sum(&:amount)
  end

  def share_queue_pending_dollar_amount
    #TODO: pick up IPO dynamically
    project.share_queue_pending.sum(&:amount) * 5
  end
  
  def self.rollover_payment_window project
    
    @project = project
    @payment_window = @project.current_payment_window
    
    #is this project ready for green light
    if !@project.green_light and @project.yellow_light and @project.yellow_light < 24.hours.ago
      PaymentWindow.create_for_project @project      
      @project.green_light = Time.now    
      @project.save!

      Notification.deliver_green_light_notification @project
      
      return
    end
    
    #dont do anything if not inpayment or a share buyout is in process
    if !@project.in_payment? or !@payment_window or @project.pmf_share_buyout
      ORDER_PROGRESS_LOG.info("SKIPPING Rolling Window For Project #{@project.id}")
      return
    end
    
    ORDER_PROGRESS_LOG.info("Attempting Roll Window For Project #{@project.id} CLOSE DATE: #{@payment_window.close_date} TODAY DATE: #{Date.today}")
    
    #allow the window to close if all payments have been collected
    #otherwise, respect the window close date
    if !@payment_window.all_payments_collected? && @payment_window.close_date > Date.today
      ORDER_PROGRESS_LOG.info("Window close date not yet reached for project #{@project.id}")
      return
    end
    
    #close the old payment window
    PaymentWindow.close_for_project @project
    
    #check for a successfull window
    if @project.finished_payment_collection
      PaymentWindow.mark_defaulted_shares @project
      return
    end
    
    #check for buyout
    if @project.payment_windows.count == 3
      ORDER_PROGRESS_LOG.info("Three windows opened for project #{@project.id} creating pmf buyout!")
      PaymentWindow.mark_defaulted_shares @project
      
      #if all conditions above are met... create the request!
      @pmf_share_buyout = PmfShareBuyout.create(:project => @project, :user => @project.owner,
        :share_amount => @project.amount_shares_outstanding_payment,
        :share_price => @project.ipo_price, :status => "Open")

      #email pmf admin
      PaymentsMailer.deliver_buyout_request @pmf_share_buyout
      
      return
    end
    
    #open a new window
    PaymentWindow.create_for_project @project
  end
  
  private
  
  def self.close_for_project project
    @project = project
    @payment_window = project.current_payment_window
    
    @notify_emails_thrown = []
    @notify_emails_paid = []

    #mark all payment_subscriptions to defaulted, that are not already marked as paid
    @payment_window.subscription_payments.each do |payment|
      if payment.paid?
        @notify_emails_paid << payment.user.profile.email
      else
        @notify_emails_thrown << payment.user.profile.email
        payment.status = "Thrown"
        payment.save!
      end
    end

    #email all users in this payment window who defaulted on payment
    @notify_emails_thrown.each do |email_address|
      begin
        PaymentsMailer.deliver_window_closed_payment_thrown @payment_window, email_address
      rescue Exception
        logger.info "Error sending mail!"
      end
    end

    #email all users in this payment window who succeeded in payment
    @notify_emails_paid.each do |email_address|
      begin
        PaymentsMailer.deliver_window_closed_payment_succeeded @payment_window, email_address
      rescue Exception
        logger.info "Error sending mail!"
      end
    end
    
    #if we have enough paid shares, mark the project as payment complete
    if @project.amount_payment_collected >= @project.capital_required
      @payment_window.status = "Successful"
      @project.mark_as_finished_payment
    else
      @payment_window.status = "Failed"
    end

    ORDER_PROGRESS_LOG.info("Closed Payment Window #{@payment_window.id} For Project #{@project.id} 
    with #{@notify_emails_paid.size} successful payments, and #{@notify_emails_thrown.size} thrown payments")
    
    @project.save!
    @payment_window.save!
  end
  
  def self.create_for_project project
    @project = project
    
    @previous_payment_window = project.payment_windows.find(:first, :order => "created_at DESC")
    
    @payment_window = PaymentWindow.new()

    @payment_window.project_id = @project.id
    @payment_window.close_date = Date.today + 3
    @payment_window.paypal_email = @project.paypal_email
    @payment_window.status = "Active"
    @payment_window.project_id = @project.id

    @payment_window.save!
    
    ORDER_PROGRESS_LOG.info("Opened payment window (ID:#{@payment_window.id}) for project #{@project.id}")
    
    #create subscription payments using the share queue
    #create a hash indexed on user ids, to work out exactly what we need to create
    @user_subscription_array = {}
    @total_amount = @project.amount_payment_collected
    @project_share_price = @project.ipo_price

    @project.share_queue.each do |subscription|
      
      break if @total_amount >= @project.capital_required

      #ignore it if it has already been used
      next if subscription.subscription_payment_id
      
      @subscription_amount_dollar = subscription.amount * @project_share_price
        
      #do we need to split a users subscription amount?
      if @total_amount + @subscription_amount_dollar > @project.capital_required
        @over_amount_dollar = (@total_amount + @subscription_amount_dollar) - @project.capital_required
        @over_amount = @over_amount_dollar / @project.ipo_price
        @actual_amount = subscription.amount
        @available_amount = @actual_amount - @over_amount

        #we must split this subscription into @over_amount and @available_amount
        subscription.amount = @available_amount
        subscription.save!

        @new_subscription = ProjectSubscription.create( :user => subscription.user,
          :project => subscription.project, :amount => @over_amount,
          :outstanding => true )
        @new_subscription.created_at = subscription.created_at
        @new_subscription.save!

        @subscription_amount_dollar = @available_amount * @project.ipo_price
      end

      if @user_subscription_array[subscription.user_id]
        @user_subscription_array[subscription.user_id][:share_amount] += subscription.amount
        @user_subscription_array[subscription.user_id][:subscription_ids] << subscription.id
      else
        @user_subscription_array[subscription.user_id] =
          {:share_price => @project_share_price, :share_amount => subscription.amount,
          :subscription_ids => [subscription.id]}
      end
      
      @total_amount += @subscription_amount_dollar
    end

    @payment_window.save!
    
    @notify_emails = []
    
    #use the thrown payments to fill the rest of the capital required
    @excess_budget_needed = @project.capital_required - @total_amount
    
    @project.subscription_payments.each do |payment|
      
      break if @excess_budget_needed == 0
      
      next unless payment.thrown?
        
      #do we need to split this payment?
      if @excess_budget_needed - payment.payment_amount < 0
        @over_share_amount = (payment.payment_amount - @excess_budget_needed) / @project.ipo_price
        @available_share_amount = @excess_budget_needed / @project.ipo_price
        
        #set the amount to the amount that is available
        payment.share_amount = @available_share_amount        
        payment.save
        
        #now create a new thrown copy for @over_share_amount
        @over_sp = SubscriptionPayment.create({:payment_window_id => @previous_payment_window.id, 
            :project_id => payment.project_id, :user_id => payment.user_id, 
            :share_amount => @over_share_amount, :share_price => payment.share_price,
            :status => "Thrown"})
        @over_sp.created_at = payment.created_at
        @over_sp.updated_at = payment.updated_at
        @over_sp.save!
      end
      
      @new_sp = SubscriptionPayment.create({:payment_window_id => @payment_window.id, 
          :project_id => payment.project_id, :user_id => payment.user_id, 
          :share_amount => payment.share_amount, :share_price => payment.share_price,
          :status => "Open"})
      
      #record a failed payment and reuse the payment in next window
      payment.status = "Reused"
      payment.reused_by_payment_id = @new_sp.id
      payment.save
      
      @notify_emails << payment.user.profile.email

      payment.project_subscriptions.each do |project_subscription|
        project_subscription.subscription_payment_id = @new_sp.id
        project_subscription.save!
      end
        
      #update budget needed
      @excess_budget_needed -= @new_sp.payment_amount
    end

    #TODO: the user_subscription array is sorted by user id, it should be sorted the same as the queue
    
    #create new subscription payments
    @user_subscription_array.each do |user_id, subscription_map|
      @user_share_amount = subscription_map[:share_amount]
      @user_share_price = subscription_map[:share_price]

      @subscription_payment = SubscriptionPayment.create(:payment_window_id => @payment_window.id,
        :project_id => @project.id, :user_id => user_id, :share_amount => @user_share_amount,
        :share_price => @user_share_price, :status => "Open")

      @notify_emails << @subscription_payment.user.profile.email

      #link all the project_subscriptions to their associated subscription payment
      @project_subscription_ids = subscription_map[:subscription_ids]

      @project_subscription_ids.each do |subscription_id|
        @subscription = ProjectSubscription.find(subscription_id)
        @subscription.subscription_payment_id = @subscription_payment.id
        @subscription.save!
      end
    end
    
    @project.project_payment_status = "In Payment"
    @project.save!

    #email all users in this payment window
    @notify_emails.each do |email_address|
      begin
        PaymentsMailer.deliver_window_opened @payment_window, email_address
      rescue Exception
        logger.info "Error sending mail!"
      end
    end
  end
  
  def self.mark_defaulted_shares project
    @project = project
    
    @failed_payment_user_ids = []
    
    @defaulted_payments_count = 0
    
    @project.subscription_payments.each do |payment|
      next unless payment.thrown?
        
      @defaulted_payments_count += 1
      
      #mark one payment as warn point per user so they only get marked once
      if !@failed_payment_user_ids.include? payment.user_id.to_s
        @failed_payment_user_ids << payment.user_id.to_s
        payment.counts_as_warn_point = true
      end
    
      payment.status = "Defaulted"
    
      payment.save!
      payment.user.update_warn_points
    end
    
    ORDER_PROGRESS_LOG.info("Project #{@project.id} finished payment collection. Marked #{@defaulted_payments_count} payments as defaulted.")
    
  end
  
end


# == Schema Information
#
# Table name: payment_windows
#
#  id           :integer(4)      not null, primary key
#  project_id   :integer(4)
#  paypal_email :string(255)
#  close_date   :date
#  status       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

