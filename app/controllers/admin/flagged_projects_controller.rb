class Admin::FlaggedProjectsController < Admin::AdminController

  before_filter :load_project, :except => :index

  def index
    @projects = Project.all_flagged.paginate :page => (params[:page] || 1), :per_page=> 8
  end

  def show
    
  end

  def unflag
    if @project.is_flagged
      @project.unflag
      flash[:positive] = "Project has been unflagged!"
    else
      flash[:error] = "Project was not flagged!"
    end

    redirect_to project_path @project
  end

  protected

  def load_project
    begin
      @project = Project.find(params[:id]) unless params[:id].blank?
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project Not Found"
      redirect_to :controller => "admin/home"
    end
  end

  def set_selected_tab
    @selected_tab_name = "flagged_projects"
  end
  
end
