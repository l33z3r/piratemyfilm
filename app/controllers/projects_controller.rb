class ProjectsController < ApplicationController
  
  skip_filter :store_location, :only => [:create, :destroy]
  skip_before_filter :login_required, :only=> [:index, :show, :search]
  before_filter :setup, :load_project
  before_filter :check_owner, :only => [:edit, :update, :destroy]  
  before_filter :search_results, :only => [:search]
  skip_before_filter :load_project, :only => [:show_private]
  before_filter :load_project_private, :only => [:show_private]
  
  PROJECT_LIST_LIMIT = 5
  
  def index
    @projects = Project.find_public(:all, :order=>"created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 8
  end

  def new
    if @u.owned_projects.size >= PROJECT_LIST_LIMIT
      flash[:negative] = "Sorry you have reached your limit of #{PROJECT_LIST_LIMIT} project listings"
      redirect_to :controller => "projects" and return
    end
      
    @project = Project.new
    @genres = Genre.find(:all)
  end

  def create
    begin
      if @u.owned_projects.size >= PROJECT_LIST_LIMIT
        flash[:negative] = "Sorry you have reached your limit of #{PROJECT_LIST_LIMIT} project listings"
        redirect_to :controller => "projects" and return
      end

      round_budget_from_params
      
      @project = Project.new(params[:project])
      @project.percent_funded = 0
      @project.owner = @u
      @genres = Genre.find(:all)      
      render :action=>'new' and return unless @project.valid?
      @project.save!
      @project.update_funding
      flash[:positive] = "Your project has been submitted for review and will appear on the site shortly!"
      redirect_to :controller => "home"
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Project"      
      @genres = Genre.find(:all)
      flash[:negative] = "Sorry, there was a problem creating your project"
      render :action=>'new'
    end
  end

  def show
    perform_show
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
        @project.update_funding
        flash[:positive] = "Your project has been updated."
        redirect_to project_path(@project)
      rescue ActiveRecord::RecordInvalid
        logger.debug "Error creating Project"      
        @genres = Genre.find(:all)
        flash[:negative] = "Sorry, there was a problem updating your project"
        render :action=>'edit'
      end            
    end 
  end

  def destroy
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

  def perform_show
    #load the users subscription to this project
    @my_subscription = ProjectSubscription.find_by_user_id_and_project_id(@u, @project)

    @max_subscription = ProjectSubscription.max_subscriptions
    @max_subscription_reached = @my_subscription && @my_subscription.amount == @max_subscription

    @admin_rating = @project.admin_project_rating ? @project.admin_project_rating.rating_symbol : AdminProjectRating.ratings_map[1]
    @admin_comment = ProjectComment.find_by_project_id @project.id

    @user_project_rating = ProjectRating.find_by_project_id @project.id
    @user_rating = @user_project_rating ? @user_project_rating.rating_symbol : ProjectRating.ratings_map[1]

    #has this user rated this project
    @my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project, @u)

    #load rating select opts
    @admin_rating_select_opts = AdminProjectRating.rating_select_opts
    @rating_select_opts = ProjectRating.rating_select_opts

    @premium_price_assumption = 5.0
    @return_premium_sales_based_on = 100000
    @return_premium_ads_based_on = 100000

    if @project.share_percent_downloads > 0
      @return_premium_sales = ((@premium_price_assumption * @return_premium_sales_based_on) * (@project.share_percent_downloads / 100.0)) / @project.total_copies
      @breakeven_premium_sales = (@premium_price_assumption * 100 * @project.total_copies) / (@project.share_percent_downloads * @premium_price_assumption)
    else
      @return_premium_sales = 0
      @breakeven_premium_sales = 0
    end
  end

  def allow_to
    super :all, :only => [:index, :show, :show_private, :search]
    super :admin, :all => true
    super :user, :only => [:new, :create, :edit, :update, :delete, :delete_icon]
  end  
  
  def check_owner
    if @project.owner != @u
      flash[:error] = 'You are not the owner of this project.'
      redirect_to project_path(@project)     
    end
  end
  
  def setup
    @profile = Profile[params[:profile_id]] if params[:profile_id]
    @user = @profile.user if @profile
    
  end

  def load_project
    @project = Project.find_public(params[:id]) unless params[:id].blank?
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

      logger.debug "!!!!!!!!!!!!#{@unrounded_budget % @premium_copy_price}"
      if @unrounded_budget % @premium_copy_price != 0
        @trim = @unrounded_budget % @premium_copy_price
        @trimmed_budget = @unrounded_budget - @trim
        @rounded_budget = @trimmed_budget + @premium_copy_price

        params[:project][:capital_required] = @rounded_budget.to_i
      end
    end
    
  end

end
