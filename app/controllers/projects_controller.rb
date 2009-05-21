class ProjectsController < ApplicationController
  
  skip_filter :store_location, :only => [:create, :destroy]
  skip_before_filter :login_required, :only=> [:index, :show, :search]
  before_filter :setup
  before_filter :check_owner, :only => [:edit, :update, :destroy]  
  before_filter :search_results, :only => [:search]
  
  def index
    @projects = Project.find(:all).paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 8    
  end

  def new
    @project = Project.new
    @genres = Genre.find(:all)
  end

  def create
    begin
      @project = Project.new(params[:project])
      @project.percent_funded = 0
      @project.owner = @u
      @genres = Genre.find(:all)      
      render :action=>'new' and return unless @project.valid?
      @project.save!
      flash[:positive] = "Your project has been added"
      redirect_to project_path(@project)
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Project"      
      @genres = Genre.find(:all)
      flash[:negative] = "Sorry, there was a problem creating your project"
      render :action=>'new'
    end
  end

  def show
    #load the users subscription to this project
    @my_subscription = ProjectSubscription.find_by_user_id_and_project_id(@u, @project)

    @max_subscription = ProjectSubscription.max_subscriptions
    @max_subscription_reached = @my_subscription && @my_subscription.amount == @max_subscription

    #load ratings for this project
    @admin_project_rating = AdminProjectRating.find_by_project_id @project.id
    @admin_rating = @admin_project_rating ? @admin_project_rating.rating_symbol : 1

    @user_project_rating = ProjectRating.find_by_project_id @project.id
    @user_rating = @user_project_rating ? @user_project_rating.rating_symbol : 1

    #has this user rated this project
    #@my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project, @u)

    #load rating select opts
    @admin_rating_select_opts = AdminProjectRating.rating_select_opts
    @rating_select_opts = ProjectRating.rating_select_opts
    
  end

  def edit
    @genres = Genre.find(:all) 
  end

  def update
    if request.put?
      begin
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
  
  def allow_to
    super :all, :only => [:index, :show, :search]
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
    @project = Project.find(params[:id]) unless params[:id].blank?    
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

end
