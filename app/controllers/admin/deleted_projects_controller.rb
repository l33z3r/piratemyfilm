class Admin::DeletedProjectsController < Admin::AdminController

  before_filter :load_project, :except => :index
  
  def index
    @projects = Project.find(:all, :conditions => "is_deleted",
      :order=>"deleted_at desc").paginate :page => (params[:page] || 1), :per_page=> 8
  end

  def show
    if !@project.is_deleted
      flash[:error] = "Project is not deleted!"
      redirect_to :controller => "/home" and return
    end
  end

  def delete
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

  def restore
    #check the owners limits on projects listed if membership not black pearl
    @membership = @project.owner.membership.membership_type

    @user_projects = @project.owner.owned_public_projects
    @max_projects = @membership.max_projects_listed

    if @user_projects.length >= @max_projects
      flash[:error]  = "Cannot restore project, user limited to #{@max_projects} projects."
      redirect_to :action => "show", :id => @project and return
    end

    #modify the budget according to the users limits
    if @project.capital_required > @membership.funding_limit_per_project
      @project.capital_required = @membership.funding_limit_per_project
    elsif @project.capital_required < @membership.min_funding_limit_per_project
      @project.capital_required = @membership.min_funding_limit_per_project
    end
    
    #now restore the project
    @project.restore

    flash[:positive] = "Project has been restored!"
    redirect_to :controller => "/projects", :action => "show", :id => @project
  end

  def load_project
    begin
      @project = Project.find(params[:id]) unless params[:id].blank?
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project Not Found"
      redirect_to :controller => "admin/home"
    end
  end

  def set_selected_tab
    @selected_tab_name = "deleted_projects"
  end
  
end
