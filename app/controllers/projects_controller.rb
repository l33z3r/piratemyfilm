class ProjectsController < ApplicationController
  
  skip_filter :store_location, :only => [:create, :delete]
  skip_before_filter :login_required, :only=> [:index, :show, :blogs, :search, :filter_by_param]
  before_filter :setup, :load_project
  skip_before_filter :setup, :only => [:blogs]
  before_filter :search_results, :only => [:search]
  skip_before_filter :load_project, :only => [:show_private, :restore, :delete]
  before_filter :load_project_private, :only => [:show_private, :restore, :delete]
  before_filter :check_owner_or_admin, :only => [:edit, :update, :delete]
  
  before_filter :load_membership_settings, :only => [:new, :create]

  cache_sweeper :project_sweeper, :only => [:update, :create, :delete, :restore]

  def index
    if @filter_param = params[:filter_param]
      @filtered = true      

      # essentially a switch statement:
      order = case @filter_param
      when "% funds reserved" then "percent_funded DESC"
      when  "member rating" then "member_rating DESC"
      when  "admin rating" then "admin_rating DESC"
      when  "newest" then "created_at DESC"
      when  "oldest" then "created_at ASC"
      when "breakeven" then "breakeven_views"
      else "created_at DESC"
        # we still have to decide what algorithm we're going to use here for "most active"
      end
      
      @projects = Project.find_all_public(:order=> order).paginate :page => (params[:page] || 1), :per_page=> 10
      
    else
      @filtered = false
      @projects = Project.find_all_public(:order=>"percent_funded DESC").paginate :page => (params[:page] || 1), :per_page=> 10
    end
  end

  def filter_by_param
    redirect_to(:action => "index", :filter_param => params[:filter_param])
  end

  def new
    unless @project_limit == -1
      if @u.owned_public_projects.size >= @project_limit
        flash[:error] = "Sorry you have reached your limit of #{@project_limit} project listings"
        redirect_to :controller => "projects" and return
      end
    end
      
    @project = Project.new
    @project.genre_id ||= Genre.default.id
    @genres = Genre.find(:all)
  end

  def create
    begin
      unless @project_limit == -1
        if @u.owned_public_projects.size >= @project_limit
          flash[:error] = "Sorry you have reached your limit of #{project_limit} project listings"
          redirect_to :controller => "projects" and return
        end
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
      @project.update_funding
      @hide_filter_params = true

      flash[:positive] = "Project Created!"
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Project"      
      @genres = Genre.find(:all)
      flash[:error] = "Sorry, there was a problem creating your project"
      render :action=>'new'
    end
  end

  def show
    if !@project
      flash[:error] = "Sorry, that project was not found. It may have been deleted or is awaiting admin verification!"
      redirect_to :action=>'index' and return
    end

    @project_blogs = @latest_project_blog = nil
    
    unless @project.blogs.empty?
      @latest_project_blog = @project.blogs.last
      @project_blogs = @project.blogs.find(:all, :order => "created_at desc", :limit => 5)
    end
    
    perform_show
  end

  def blogs
    @project_blogs = Project.find(params[:id]).blogs(:all, :order => "created_at desc")
    @project_id = params[:id]
  end

  def show_private
    perform_show
    render :action => "show"
  end

  def edit
    @genres = Genre.find(:all)
  end

  def update
    if request.put?
      begin

        round_budget_from_params
      
        @project.update_attributes(params[:project])
        @project.save!
        @project.update_funding_and_estimates
        
        flash[:positive] = "Your project has been updated."
        redirect_to project_path(@project)
      rescue ActiveRecord::RecordInvalid
        logger.debug "Error creating Project"      
        @genres = Genre.find(:all)
        flash[:error] = "Sorry, there was a problem updating your project"
        render :action=>'edit'
      end            
    end 
  end

  def delete
    if !@project
      flash[:error] = "Sorry, that project was not found. It may have been deleted or is awaiting admin verification!"
      render :action=>'index' and return
    end

    @project.delete

    #must delete all subscribtions to this project
    @subscriptions = ProjectSubscription.find_all_by_project_id(@project)
    @subscriptions.each do |subscription|
      subscription.destroy
    end
      
    flash[:positive] = "Project has been deleted!"
    redirect_to :action => "index"
  end

  def restore
    if !@project
      flash[:error] = "Sorry, that project was not found. It may have been deleted or is awaiting admin verification!"
      render :action=>'index' and return
    end

    @project.is_deleted = false
    @project.deleted_at = nil
    @project.save!

    flash[:positive] = "Project has been restored!"
    redirect_to :action => "show", :id => @project
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
  
  protected

  def load_membership_settings
    @project_limit = @u.membership_type.max_projects_listed
  end

  def perform_show

    @my_subscription = ProjectSubscription.find_by_user_id_and_project_id(@u, @project)

    #a user can only have pc_limit pcs per project
    @max_subscription_reached = false

    if @u
      @max_subscription = @u.membership_type.pc_limit

      if @my_subscription and (@max_subscription != -1)
        @max_subscription_reached = @my_subscription.amount >= @max_subscription
      end
    end

    #a user can have a pcs in a maximum of pc_project_limit projects
    @max_project_subscription_reached = false

    if @u and !@my_subscription
      @number_projects_subscribed_to = @u.project_subscriptions.size
      @max_overall_project_subscriptions = @u.membership_type.pc_project_limit
      unless @max_overall_project_subscriptions == -1
        @max_project_subscription_reached = @number_projects_subscribed_to >= @max_overall_project_subscriptions
      end
    end
    
    @admin_rating = @project.admin_rating
    @admin_comment = @project.admin_comment
    @user_rating = @project.user_rating

    #has this user rated this project
    @my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project, @u, :order => "created_at DESC", :limit => "1")
    @selected_my_project_rating = @my_project_rating ? [@my_project_rating.rating, @my_project_rating.rating.to_s] : nil

    #check if user can rate this project
    @allowed_to_rate = !@my_project_rating || @my_project_rating.created_at < Time.now.beginning_of_day

    #load rating select opts
    @admin_rating_select_opts = AdminProjectRating.rating_select_opts
    @current_admin_rating = @project.admin_project_rating ? @project.admin_project_rating.rating.to_s : 1;
    @rating_select_opts = ProjectRating.rating_select_opts
    @selected_admin_rating = [@admin_rating, @current_admin_rating]
  end

  def allow_to
    super :all, :only => [:index, :show, :blogs, :search, :filter_by_param]
    super :admin, :all => true
    super :user, :only => [:new, :create, :show_private, :edit, :update, :delete, :delete_icon]
  end  
  
  def check_owner
    if !@project
      flash[:error] = "Sorry, that project was not found. It may have been deleted or is awaiting admin verification!"
      redirect_to :action=>'index' and return
    end
    
    if @project.owner != @u
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
      flash[:error] = "Project Not Found"
      redirect_to :controller => "home"
    end
  end

  def load_project_private
    @project = Project.find(params[:id]) unless params[:id].blank?

    #test permissions on this project
    raise 'You do not have permission to view this project!' unless @project.owner == @u or @u.is_admin
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

end
