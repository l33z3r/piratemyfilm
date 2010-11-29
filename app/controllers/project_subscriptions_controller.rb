class ProjectSubscriptionsController < ApplicationController

  before_filter :load_project, :get_project_subscriptions, :except => :pmf_sub
  skip_before_filter :login_required, :only=> [:pmf_sub]

  cache_sweeper :project_sweeper, :only => [:create, :destroy]

  def create
    begin            

      #if we are the pmf_fund
      if @u.id == PMF_FUND_ACCOUNT_ID
        pmf_fund_reserve and return
      end

      #check that this project is no already in payment
      check_project_in_payment

      if !allowed_reserve_shares
        flash[:error] = "As the owner of this project, you cannot reserve shares!"
        redirect_to project_path(@project) and return
      end

      if ProjectSubscription.pc_project_limit_reached(@u, @project)
        flash[:error] = "You cannot reserve any shares in this project"
        redirect_to project_path(@project) and return
      end

      @num_shares = params[:num_shares].to_i
      
      if !@num_shares || @num_shares <= 0
        flash[:error] = "Make sure you enter a number bigger than 0"
        redirect_to project_path(@project) and return
      end

      #can the user reserve this amount of shares?
      @num_shares_allowed = ProjectSubscription.num_shares_allowed(@u, @project)

      if @num_shares_allowed < @num_shares
        flash[:error] = "You can only reserve #{@num_shares_allowed} at this time"
        redirect_to project_path(@project) and return
      end

      @num_outstanding_shares = 0
      @downloads_available = @project.downloads_available < 0 ? 0 : @project.downloads_available

      if @num_shares > @downloads_available
        @num_outstanding_shares = @num_shares - @downloads_available
        @num_shares = @downloads_available
      end

      #create non outstanding shares
      if @num_shares > 0
        @project_subscription = ProjectSubscription.create( :user => @u,
          :project => @project, :amount => @num_shares, :outstanding => false )
      end

      #create outstanding shares
      if @num_outstanding_shares > 0
        @outstanding_project_subscription = ProjectSubscription.create(:user => @u,
          :project => @project, :amount => @num_outstanding_shares, :outstanding => true)
      end

      @following = ProjectFollowing.find_by_user_id_and_project_id(@u, @project)

      if !@following
        @project_subscription = ProjectFollowing.create( :user => @u, :project => @project)
      end

      ProjectSubscription.update_share_queue @project

      flash[:notice] = "Reservation Complete"
      
    rescue ActiveRecord::RecordInvalid => ex
      logger.error "Error during reservation! #{ex.message}"
      flash[:error] = "Error During Reservation"
    end
    
    redirect_to project_path(@project)    
  end

  def cancel
    begin            
      
      if !allowed_cancel_shares
        flash[:error] = "As the owner of this project, you cannot cancel shares!"
        redirect_to project_path(@project) and return
      end

      @num_shares = params[:num_shares].to_i

      if !@num_shares || @num_shares <= 0
        flash[:error] = "Make sure you enter a number bigger than 0"
        redirect_to project_path(@project) and return
      end

      @my_subscriptions_amount = ProjectSubscription.calculate_amount(@project_subscriptions)

      if @num_shares > @my_subscriptions_amount
        flash[:error] = "You do not have that many shares to cancel"
        redirect_to project_path(@project) and return
      end

      ProjectSubscription.cancel_shares_for_project(@project_subscriptions, @num_shares)

      ProjectSubscription.update_share_queue @project

      if @u.id == PMF_FUND_ACCOUNT_ID
        #store in reservation history for pmf fund
        PmfFundSubscriptionHistory.create(:project => @project, :amount => (0 - @num_shares))
      end

      flash[:notice] = "Shares canceled!"
      
    rescue ActiveRecord::RecordInvalid => ex
      logger.error "Error canceling shares! #{ex.message}"
      flash[:error] = "Error canceling shares in this project"
    end
    
    redirect_to project_path(@project)
  end

  def pmf_sub
    if params[:pmf_sub_id]
      @pmf_project_subscription_change = PmfFundSubscriptionHistory.find(params[:pmf_sub_id])
    else
      flash[:error] = "Subscription not found"
      redirect_to home_path
    end
  end

  protected

  def allow_to
    super :admin, :all => true
    super :user, :only => [:create, :cancel]
    super :all, :only => [:pmf_sub]
  end
  
  def get_project_subscriptions
    @project_subscriptions = ProjectSubscription.load_subscriptions(@u, @project)
  end

  def check_project_in_payment
    if @project.in_payment
      flash[:error] = "You cannot reserve/cancel shares, as this project is now in payment!"
      redirect_to project_path(@project) and return
    end
  end
  
  def load_project
    begin
      @project = Project.find(params[:project_id])
      logger.debug "Found project #{@project}"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  #pmf fund shares go 1st in the queue
  def pmf_fund_reserve
    @num_shares = params[:num_shares].to_i

    #can the user reserve this amount of shares?
    @num_shares_allowed = ProjectSubscription.num_shares_allowed(@u, @project)

    if @num_shares_allowed < @num_shares
      flash[:error] = "You can only reserve #{@num_shares_allowed} at this time"
      redirect_to project_path(@project) and return
    end

    #initialize num_normal_shares
    @num_normal_shares = @num_shares
    
    @num_outstanding_shares = 0
    
    @downloads_available = @project.total_copies

    @current_subscriptions = ProjectSubscription.load_subscriptions(@u, @project)
    @current_amount_held = ProjectSubscription.calculate_amount(@current_subscriptions)
    
    if (@num_shares + @current_amount_held) > @downloads_available
      @num_normal_shares = @downloads_available - @current_amount_held

      @num_normal_shares = 0 if @num_normal_shares < 0

      @num_outstanding_shares = @num_shares - @num_normal_shares
    end

    #create non outstanding shares
    if @num_normal_shares > 0
      @project_subscription = ProjectSubscription.create( :user => @u,
        :project => @project, :amount => @num_normal_shares, :outstanding => false)
    end

    #create outstanding shares
    if @num_outstanding_shares > 0
      @outstanding_project_subscription = ProjectSubscription.create(:user => @u,
        :project => @project, :amount => @num_outstanding_shares, :outstanding => true)
    end

    if @project_subscription
      @project_subscription.created_at = Time.at(0)
      @project_subscription.save
    end

    if @outstanding_project_subscription
      @outstanding_project_subscription.created_at = Time.at(0)
      @outstanding_project_subscription.save
    end

    @following = ProjectFollowing.find_by_user_id_and_project_id(@u, @project)

    if !@following
      @project_subscription = ProjectFollowing.create( :user => @u, :project => @project)
    end
      
    #store in reservation history for pmf fund
    PmfFundSubscriptionHistory.create(:project => @project, :amount => @num_shares)

    ProjectSubscription.update_share_queue @project

    flash[:notice] = "Reservation Complete"

    redirect_to project_path(@project)
  end

end
