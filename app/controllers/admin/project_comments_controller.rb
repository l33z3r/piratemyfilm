class Admin::ProjectCommentsController < ApplicationController
  #added by Paul, all

  def update_comment
    begin
      @project_id = params[:project_id]

      @current_comment = ProjectComment.find_by_project_id(@project_id)

      unless @current_comment
        @current_comment = ProjectComment.create
      end

      @body = params[:body]
      @current_comment.body = @body
      @current_comment.user_id = @u.id
      @current_comment.project_id = @project_id
      @current_comment.save!

      flash[:positive] = "Project Commented!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id

    rescue ActiveRecord::RecordInvalid
      flash[:negative] = "Error commenting on project!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id
    end
  end

  private

  def allow_to
    super :admin, :all => true
  end
  
end
