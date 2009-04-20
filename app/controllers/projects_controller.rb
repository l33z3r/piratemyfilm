class ProjectsController < ApplicationController
  
  skip_filter :store_location, :only => [:create, :destroy]
  skip_before_filter :login_required, :only=> [:index, :show]
  before_filter :setup
  
  def index
    @projects = Project.find(:all).paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 5    
  end

  def new
    @project = Project.new
    @genres = Genre.find(:all)
  end

  def create
    begin
      @project = Project.new(params[:project])
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
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
  protected
  
  def setup
    @profile = Profile[params[:profile_id]] if params[:profile_id]
    @user = @profile.user if @profile
    @project = Project.find(params[:id]) unless params[:id].blank?    
  end
    
  def allow_to
    super :all, :only => [:index, :show]
    super :admin, :all => true
    super :user, :only => [:new, :create, :update, :delete]
  end      

end
