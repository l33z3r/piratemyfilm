class PaymentWindowController < ApplicationController
  before_filter :load_project, :check_owner_or_admin, :except => "mark_payment_paid"
  
  def new
    @payment_window = PaymentWindow.new
  end
    
  def create
    #must have green light
    if !@project.green_light
      flash[:error] = "Project has not been given green light by admin"
      redirect_to project_path @project and return
    end

    #has project already collected all funds
    if @project.project_payment_status == "Finished Payment"
      flash[:error] = "All funds have already been collected for this project!"
      redirect_to project_path @project and return
    end

    #must not have window open already
    if @project.current_payment_window
      flash[:error] = "There is already an active payment window for this project!"
      redirect_to project_path @project and return
    end

    @payment_window = PaymentWindow.new(params[:payment_window])

    #make sure the date is in the future only on window creation
    if @payment_window.close_date <= (Date.today + 7)
      flash[:error] = "Payment Window closing date must be set to at least a week in the future!"
      render :action => "new" and return
    end

    @payment_window.status = "Active"
    @payment_window.project_id = @project.id

    #create subscription payments using the share queue
    #create a hash indexed on user ids, to work out exactly what we need to create
    @user_subscription_array = {}
    @total_amount = @project.amount_payment_collected
    @project_share_price = @project.ipo_price

    @project.share_queue.each do |subscription|
      
      break if @total_amount >= @project.capital_required

      #check this subscription has not already been used in a previous window
      if subscription.subscription_payment_id
        next
      end

      if @user_subscription_array[subscription.user_id]
        @user_subscription_array[subscription.user_id][:share_amount] += subscription.amount
        @user_subscription_array[subscription.user_id][:subscription_ids] << subscription.id
      else
        @user_subscription_array[subscription.user_id] =
          {:share_price => @project_share_price, :share_amount => subscription.amount,
          :subscription_ids => [subscription.id]}
      end

      @total_amount += (subscription.amount * @project_share_price)
    end

    if @user_subscription_array.size == 0
      flash[:error] = "There are no more subscriptions in the queue, you must request that pmf buys out the rest of your outstanding shares!"
      redirect_to project_path @project and return
    end

    begin
      @payment_window.save!
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error Creating Payment Window"
      render :action=>'new' and return
    end

    @notify_emails = []
    
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
    
    flash[:positive] = "Payment Window Created! Users will be notified that they must submit payment for their shares!"
    redirect_to :controller => "payment_window", :action => "show", :id => @project.id
  end

  def close
    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project!"
      redirect_to project_path @project and return
    end

    @notify_emails_defaulted = []
    @notify_emails_paid = []

    #mark all payment_subscriptions to defaulted, that are not already marked as paid
    @payment_window.subscription_payments.each do |payment|
      if payment.paid?
        @notify_emails_paid << payment.user.profile.email
      else
        @notify_emails_defaulted << payment.user.profile.email
        payment.status = "Defaulted"
        payment.save!
      end
    end

    #email all users in this payment window who defaulted on payment
    @notify_emails_defaulted.each do |email_address|
      begin
        PaymentsMailer.deliver_window_closed_payment_failed @payment_window, email_address
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
      @project.payment_status = "Finished Payment"
    else
      @payment_window.status = "Failed"
    end

    @project.save!
    @payment_window.save!

    flash[:positive] = "Payment Window Closed!"
    redirect_to project_path @project
  end

  def show
    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project"
      redirect_to :action => "history", :id => @project
    end
  end

  def history
    @current_payment_window = @project.current_payment_window
    @previous_payment_windows = @project.payment_windows.find(:all, :conditions => "status != 'Active'")
  end

  def mark_payment_paid
    #only allow post
    return unless request.post?

    #users can only mark as paid, the system will mark shares as defaulted when a payment window is closed
    begin
      @subscription_payment = SubscriptionPayment.find(params[:id])

      @payment_window = @subscription_payment.project.current_payment_window

      if !@payment_window
        flash[:error] = "There is no active payment window for this project"
        redirect_to :action => "history", :id => @project
      end

      if @subscription_payment.status == "Pending"
        @subscription_payment.status = "Paid"

        #email all users in this payment window who succeeded in payment
        begin
          PaymentsMailer.deliver_payment_succeeded @payment_window, @subscription_payment.user.profile.email
        rescue Exception
          logger.info "Error sending mail!"
        end
    
        @subscription_payment.save!
      else
        flash[:error] = "This payment has already been marked as #{@subscription_payment.status}"
        redirect_to project_path @project and return
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Subscription Payment Not Found"
      redirect_to project_path @project
    end

    flash[:positive] = "Payment has been marked as paid!"
    redirect_to :controller => "payment_window", :action => "show", :id => @subscription_payment.project.id
  end

  protected

  def load_project
    begin
      @project = Project.find_single_public(params[:id]) unless params[:id].blank?
    rescue ActiveRecord::RecordNotFound
      @project = nil
    end

    if !@project
      flash[:error] = "Project Not Found"
      redirect_to :controller => "home"
    end
  end

  def check_owner_or_admin
    if @project.owner != @u && !@u.is_admin
      flash[:error] = 'You are not the owner of this project.'
      redirect_to project_path(@project)
    end
  end

  def allow_to
    super :admin, :all => true
    super :user, :all => true
  end
  
end
