class ProjectCommentsController < ApplicationController
  skip_before_filter :login_required
  before_filter :load_project, :only => :index
  before_filter :check_admin, :only => [:edit, :update, :destroy]
  before_filter :load_comment, :only => [:show, :edit, :update, :destroy]

  def latest
    @project_comments = ProjectComment.latest.paginate :page => (params[:page] || 1), :per_page=> 15
  end

  def index
    @project_comments = @project.project_comments
  end

  def show
    
  end

  def edit

  end

  def update
    if request.put?
      begin
        @project_comment.update_attributes!(params[:project_comment])
        flash[:positive] = "Comment has been updated."
        redirect_to project_comment_path(@project_comment)
      rescue ActiveRecord::RecordInvalid
        flash[:error] = "Error Updating Comment"
        render :action=>'edit'
      end
    end
  end
  
  def destroy
    @project_comment.destroy
    flash[:positive] = "Comment Deleted!"
    redirect_to home_path
  end

  private

  def check_admin
    @u && @u.is_admin
  end

  def load_project
    begin
      @project = Project.find_single_public(params[:project_id]) unless !params[:project_id]
    rescue ActiveRecord::RecordNotFound
      @project = nil
    end

    if !@project
      flash[:error] = "Project Not Found"
      redirect_to :controller => "home" and return
    end
  end

  def load_comment
    begin
      @project_comment = ProjectComment.find(params[:id]) unless !params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Project Comment Not Found"
      redirect_to :controller => "home" and return
    end

    if @project_comment.project.is_deleted
      flash[:error] = "Project Not Found"
      redirect_to :controller => "home" and return
    end
  end
  
  def allow_to
    super :all, :all => true
  end
end
