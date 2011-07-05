class ProjectsController < ApplicationController
  
  skip_filter :store_location, :only => [:create]
  skip_before_filter :login_required, :only => [:index, :show, :player, :blogs, :search, :filter_by_param]

  before_filter :setup

  before_filter :load_project, :only => [:show, :edit, :player, :update, :delete, :update_symbol,
    :update_green_light, :share_queue, :blogs, :invite_friends, :send_friends_invite, 
    :flag, :buy_shares, :add_talent]

  skip_before_filter :setup, :only => [:blogs]
  before_filter :search_results, :only => [:search]
  before_filter :check_owner_or_admin, :only => [:edit, :update, :delete, :share_queue]
  before_filter :check_admin, :only => [:update_green_light]

  before_filter :load_membership_settings, :only => [:new, :create]

  cache_sweeper :project_sweeper, :only => [:update, :create]

  def index
    if @filter_param = params[:filter_param]
      @filter = Project.get_filter_sql @filter_param
      @order = Project.get_order_sql @filter_param

      @projects = Project.find_all_public(:select => '*, percent_funded + pmf_fund_investment_percentage AS percent_funded_total', :conditions => @filter, :order=> @order).paginate :page => (params[:page] || 1), :per_page=> 15
    else
      @projects = Project.find_all_public(:order => "percent_funded DESC, rated_at DESC, created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 15
    end
  end

  def filter_by_param
    redirect_to(:action => "index", :filter_param => params[:filter_param])
  end

  def new
    if @u.owned_public_projects.size >= @project_limit
      flash[:error] = "Sorry you have reached your limit of #{@project_limit} project listings"
      redirect_to :controller => "projects" and return
    end
      
    @project = Project.new
    @project.genre_id ||= Genre.default.id
    @genres = Genre.find(:all, :order => "title")
  end

  def create
    begin
      if @u.owned_public_projects.size >= @project_limit
        flash[:error] = "Sorry you have reached your limit of #{@project_limit} project listings"
        redirect_to :controller => "projects" and return
      end

      round_budget_from_params
      
      @project = Project.new(params[:project])
      @project.percent_funded = 0
      @project.owner = @u
      @genres = Genre.find(:all)
      
      render :action=>'new' and return unless @project.valid?

      #verify captcha
      render :action=>'new' and return unless check_captcha(false)

      @project.save!
      @hide_filter_params = true

      @project_subscription = ProjectFollowing.create( :user => @u, :project => @project)

      Notification.deliver_project_listed_notification @project

      flash[:positive] = "Project Created!"
      redirect_to project_path(@project)
    rescue ActiveRecord::RecordInvalid
      logger.info "Error creating Project"
      @genres = Genre.find(:all)
      flash[:error] = "Sorry, there was a problem creating your project"
      render :action=>'new'
    end
  end

  def buy_shares
    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project"
      redirect_to project_path(@project) and return
    end

    @ps = @u.subscription_payments.find(params[:subscription_payment_id])

    if !@ps
      flash[:error] = "Cannot find subscription!"
      redirect_to project_path(@project) and return
    end

    @warn = true

    #mark payment as pending verification
    if @ps.open?
      @warn = false
      @ps.status = "Pending"
      @ps.save!
    end

    #load the paypal submission url
    @paypal_url = CUSTOM_CONFIG['paypal_button_submission_url']
    
    perform_show
  end

  def update_symbol
    begin
      @project.symbol = params[:project][:symbol]
      @project.save!

      flash[:positive] = "Symbol updated."
      redirect_to project_path(@project)
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error updating symbol"
      perform_show
      render :action => "show"
    end
  end

  def player
    if !@project.main_video
      flash[:error] = "This project has no video attatched to it."
      redirect_to :action => "show", :id => @project
    end
  end

  def update_green_light
    begin
      #we only allow granting of green light for now
      return if @project.green_light
    
      if !@project.budget_reached_include_pmf?
        flash[:error] = "Project must have 100% budget to be Green!"
        redirect_to project_path(@project) and return
      end
        
      @project.green_light = Time.now
      @project.save!

      Notification.deliver_green_light_notification @project
      
      flash[:positive] = "Project Updated."
      redirect_to project_path(@project)
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error updating project"
      perform_show
      render :action => "show"
    end
  end

  def share_queue
    @subscriptions = @project.share_queue
  end

  def show
    perform_show
  end

  def blogs
    @blogs = @project.blogs(:all, :order => "created_at desc").paginate :page => (params[:page] || 1), :per_page=> 15
  end

  def edit
    @genres = Genre.find(:all, :order => "title")
  end

  def update
    if request.put?
      begin
        @genres = Genre.find(:all)

        round_budget_from_params

        @project.update_attributes!(params[:project])
        
        flash[:positive] = "Your project has been updated."
        redirect_to project_path(@project)
      rescue ActiveRecord::RecordInvalid
        logger.debug "Error Updating Project"
        flash[:error] = "Sorry, there was a problem updating your project"
        render :action => "edit"
      end            
    end 
  end

  def delete

    if @project.green_light
      flash[:error] = "You cannot delete the project as it is in the green light stage!"
      redirect_to project_path(@project) and return
    end
    
    #must delete all subscribtions to this project
    @subscriptions = ProjectSubscription.find_all_by_project_id(@project)
    @subscriptions.each do |subscription|
      subscription.destroy
    end

    #reset the member rating by deleting the member rating history
    @project.project_rating.destroy unless !@project.project_rating

    @project.delete

    flash[:positive] = "Project has been deleted!"
    redirect_to :controller => "/home", :action => "index"
  end
  
  def search
    render
  end
  
  def delete_icon
    respond_to do |wants|
      @project.update_attribute :icon, nil
      wants.js {render :update do |page| page.visual_effect 'Puff', 'project_icon_picture' end  }
    end
  end

  def invite_friends
    
  end

  def flag
    if !@u.flagged_project? @project
      ProjectFlagging.create(:project => @project, :user => @u)
      flash[:positive] = "This project has been flagged as inappropriate content and will be reviewed!"
    else
      flash[:error] = "You have already flagged this project."
    end

    redirect_to project_path(@project)
  end
  
  def send_friends_invite
    @email_addresses = params[:email_addresses].split(/, /)

    @email_addresses.each do |email_address|
      begin
        ProjectsMailer.deliver_follow_invitation @u, @project, email_address
      rescue Exception
      end
    end

    flash[:positive] = "Your invitation has been sent."
    redirect_to project_path(@project)
  end
  
  def add_talent
    @user_talent = UserTalent.find(params[:talent_id])
    
    #check that we are not exceeding max allowed talents
    @existing_puts_for_type = ProjectUserTalent.find(:all, :include => "user_talent", :conditions => "project_id = #{@project.id} and user_talents.talent_type = '#{@user_talent.talent_type}'")
    
    @exceeding_amount = false
    
    if @existing_puts_for_type.size >= UserTalent.max_talents_allowed
      @exceeding_amount = true
    end
    
    @pt = ProjectUserTalent.find_or_initialize_by_project_id_and_user_talent_id({:project_id => @project.id, :user_talent_id => @user_talent.id})
    
    if @pt.new_record?
      @pt.save
    else
      @pt = nil
    end
  end
  
  def remove_talent
    @pt_id = params[:pt_id]
    @pt = ProjectUserTalent.find(@pt_id)
    @pt.destroy
  end
  
  protected

  def load_membership_settings
    @project_limit = @u.membership_type.max_projects_listed
  end

  def perform_show

    #load project blogs
    @latest_project_blog = nil

    unless @project.blogs.empty?
      @latest_project_blog = @project.blogs.last
    end
    
    @project_blogs = @project.blogs.find(:all, :order => "created_at desc", :limit => 5)

    #load project comments
    @project_comments = nil

    unless @project.project_comments.empty?
      @project_comments = @project.project_comments.find(:all, :order => "created_at desc", :limit => 5)
    end

    if @u
      @my_subscriptions = ProjectSubscription.load_subscriptions(@u, @project)

      @max_subscription = @u.membership_type.pc_limit
    
      @my_subscriptions_amount = ProjectSubscription.calculate_amount(@my_subscriptions)

      @num_shares_allowed = ProjectSubscription.num_shares_allowed(@u, @project)

      @my_outstanding_subscriptions_amount = ProjectSubscription.calculate_outstanding_amount(@my_subscriptions)
    
      #a user can only have pc_limit pcs per project
      @max_subscription_reached = ProjectSubscription.pc_limit_reached(@u, @project)

      #a user can have a pcs in a maximum of pc_project_limit projects
      @max_project_subscription_reached = ProjectSubscription.pc_project_limit_reached(@u, @project)
    end
    
    @admin_rating = @project.admin_rating
    @user_rating = @project.user_rating

    #has this user rated this project
    @my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project, @u, :order => "created_at DESC", :limit => "1")
    @selected_my_project_rating = @my_project_rating ? [@my_project_rating.rating, @my_project_rating.rating.to_s] : [1, "1"]

    #check if user can rate this project
    @allowed_to_rate = !@my_project_rating || @my_project_rating.created_at < Time.now.beginning_of_day

    #load rating select opts
    @admin_rating_select_opts = AdminProjectRating.rating_select_opts
    @current_admin_rating = @project.admin_project_rating ? @project.admin_project_rating.rating.to_s : "1";
    @rating_select_opts = ProjectRating.rating_select_opts
    @selected_admin_rating = [@admin_rating, @current_admin_rating]
  end

  def check_admin
    if !@u || !@u.is_admin
      flash[:error] = 'You are not the owner of this project.'
      redirect_to project_path(@project)
    end
  end

  def check_owner_or_admin
    if @project.owner != @u && !@u.is_admin
      flash[:error] = 'You are not the owner of this project.'
      redirect_to project_path(@project)
    end
  end
  
  def setup
    @profile = Profile[params[:profile_id]] if params[:profile_id]
    @user = @profile.user if @profile
  end

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

  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @search_string = p.delete(:q) || ''
    @results = Project.search(@search_string, p).paginate(:page => @page, :per_page => @per_page)
  end

  def round_budget_from_params
    if params[:project][:capital_required] && params[:project][:ipo_price]
      #round the funding to multiple of premium copy price
      @unrounded_budget = params[:project][:capital_required].to_f
      @premium_copy_price = params[:project][:ipo_price].to_f

      if @unrounded_budget % @premium_copy_price != 0
        @trim = @unrounded_budget % @premium_copy_price
        @trimmed_budget = @unrounded_budget - @trim
        @rounded_budget = @trimmed_budget + @premium_copy_price

        params[:project][:capital_required] = @rounded_budget.to_i
      end
    end
  end

  def allow_to
    super :all, :only => [:index, :show, :player, :blogs, :search, :filter_by_param]
    super :admin, :all => true
    super :user, :only => [:new, :create, :edit, :update, :delete, :delete_icon, 
      :share_queue, :invite_friends, :send_friends_invite, :buy_shares, :add_talent, :remove_talent]
  end

end
