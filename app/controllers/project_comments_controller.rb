class ProjectCommentsController < ApplicationController

  skip_before_filter :login_required
  before_filter :setup, :except => :latest

  def latest
    @project_comments = ProjectComment.find(:all, :order => "created_at DESC")
  end

  def index
    @project_comments = @project.project_comments
  end

  def show
    
  end

  private

  def setup
    @project = Project.find(params[:project_id]) unless !params[:project_id]
    @project_comment = ProjectComment.find(params[:id]) unless !params[:id]
  end
  
  def allow_to
    super :all, :all => true
  end
end
