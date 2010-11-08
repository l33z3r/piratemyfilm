class Admin::NewProjectsController < Admin::AdminController

  before_filter :redirection

  def redirection
    redirect_to :controller => "/home"
  end
  
  before_filter :load_project, :except => :index

  def index
    @projects = Project.find(:all, :conditions => "symbol is null and is_deleted = 0",
      :order=>"created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 8
  end

  def show
    if @project.is_public
      flash[:error] = "Project is already public!"
      redirect_to :controller => "/home" and return
    end
  end

  def release_project
    begin
      @project.symbol = params[:project][:symbol]
      @project.save!

      flash[:positive] = "Project Released!"
      redirect_to project_path(@project)
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error updating symbol"
      render :action => "show"
    end
  end

  private

  def load_project
    begin
      @project = Project.find(params[:id]) unless params[:id].blank?
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project Not Found"
      redirect_to :controller => "admin/home"
    end
  end

  def set_selected_tab
    @selected_tab_name = "new_projects"
  end
  
end
