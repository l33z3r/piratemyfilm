class PaymentWindowController < ApplicationController
  before_filter :load_project, :except => ["mark_payment_paid", "show"]

  #we will manually check ownership in the mark_payment_paid action
  before_filter :check_owner_or_admin, :except => ["mark_payment_paid"]
  
  before_filter :check_allow_create_window, :only => ["new", "create"]
  
  def new
    @payment_window = PaymentWindow.new
  end
    
  def create
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
    redirect_to :controller => "payment_window", :action => "show_current", :id => @project.id
  end

  def pmf_buyout_request
    #only allow post
    return unless request.post?

    #must have green light
    if !@project.green_light
      flash[:error] = "Project has not been given green light by admin"
      redirect_to :action => "history", :id => @project and return
    end

    #has project already collected all funds
    if @project.finished_payment_collection
      flash[:error] = "All funds have already been collected for this project!"
      redirect_to :action => "history", :id => @project and return
    end

    #must not have window open already
    if @project.current_payment_window
      flash[:error] = "There is already an active payment window for this project!"
      redirect_to :action => "history", :id => @project and return
    end

    #is there a request pending
    if !@project.share_queue_exhausted?
      flash[:error] = "You cannot create this request as there are still users in the queue who will buy out your outstanding shares!"
      redirect_to :action => "history", :id => @project and return
    end

    if @project.pmf_share_buyout
      flash[:error] = "There is already a request created for this project. It will be dealt with shorlty!"
      redirect_to :action => "history", :id => @project and return
    end

    #if all conditions above are met... create the request!
    PmfShareBuyout.create(:project => @project, :user => @project.owner,
      :share_amount => @project.amount_shares_outstanding_payment,
      :share_price => @project.ipo_price, :status => "Open")

    flash[:positive] = "Your request has been created and will be dealt with shortly!"
    redirect_to :action => "history", :id => @project

  end

  def pmf_buyout_request_paid
    #only allow post
    return unless request.post?

    #do not need to perform all the state checks for the project,
    #as they were done when the initial buyout request was created
    @project.pmf_share_buyout.status = "Verified"
    @project.pmf_share_buyout.save!

    @project.project_payment_status = "Finished Payment"
    @project.save!
    
    flash[:positive] = "Payment Confirmed!"
    redirect_to :action => "history", :id => @project
  end
  
  def close
    #only allow post
    return unless request.post?

    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project!"
      redirect_to :action => "history", :id => @project and return
    end

    #payment window date must have elapsed
    if @payment_window.close_date > Date.today
      flash[:error] = "It has not passed the payment window close date, you must wait till then to close this window!"
      redirect_to :action => "history", :id => @project and return
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
      @project.project_payment_status = "Finished Payment"
    else
      @payment_window.status = "Failed"
    end

    @project.save!
    @payment_window.save!

    flash[:positive] = "Payment Window Closed!"
    redirect_to :action => "history", :id => @project
  end

  def show
    begin
      @payment_window = PaymentWindow.find(params[:id])
      @project = @payment_window.project
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Payment Window Not Found"
      redirect_to :controller => "home"
    end
  end

  def show_current
    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project"
      redirect_to :action => "history", :id => @project
    end

    render :action => "show"
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

      @project = @subscription_payment.project

      #manually check permissions
      if @project.owner != @u && !@u.is_admin
        flash[:error] = 'You are not the owner of this project.'
        redirect_to project_path(@project) and return
      end

      @payment_window = @subscription_payment.payment_window

      if !@payment_window.open?
        flash[:error] = "This payment window is not active"
        redirect_to :action => "history", :id => @project and return
      end

      if @subscription_payment.pending?
        @subscription_payment.status = "Paid"

        #email all users in this payment window who succeeded in payment
        begin
          PaymentsMailer.deliver_payment_succeeded @payment_window, @subscription_payment.user.profile.email
        rescue Exception
          logger.info "Error sending mail!"
        end
    
        @subscription_payment.save!

        #check is this window finished... close it if it is

      elsif @subscription_payment.paid?
        flash[:error] = "This payment has already been marked as Paid"
        redirect_to :action => "show_current", :id => @subscription_payment.project and return
      elsif @subscription_payment.open?
        flash[:error] = "This payment cannot be marked as paid, as the user has not yet clicked the 'Pay For Shares' button."
        redirect_to :action => "show_current", :id => @subscription_payment.project and return
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Subscription Payment Not Found"
      redirect_to :action => "show_current", :id => @subscription_payment.project and return
    end

    flash[:positive] = "Payment has been marked as paid!"
    redirect_to :controller => "payment_window", :action => "show_current", :id => @subscription_payment.project.id
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

  def check_allow_create_window
    #must have green light
    if !@project.green_light
      flash[:error] = "Project has not been given green light by admin"
      redirect_to :action => "history", :id => @project and return
    end

    #has project already collected all funds
    if @project.finished_payment_collection
      flash[:error] = "All funds have already been collected for this project!"
      redirect_to :action => "history", :id => @project and return
    end

    #must not have window open already
    if @project.current_payment_window
      flash[:error] = "There is already an active payment window for this project!"
      redirect_to :action => "history", :id => @project and return
    end
    
    #must be users left in the share queue
    if @project.share_queue_exhausted?
      flash[:error] = "There are no users left in the share queue to offer outstanding shares to.
        You must request that PMF buy out the remaining shares."
      redirect_to :action => "history", :id => @project and return
    end
    
  end

end
