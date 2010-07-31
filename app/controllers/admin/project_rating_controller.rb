class Admin::ProjectRatingController < Admin::AdminController

  def rate
    begin
      @project_id = params[:project_id]
      @project = Project.find_by_id(@project_id)

      @current_rating = AdminProjectRating.find_by_project_id @project_id

      if !@current_rating
        @current_rating = AdminProjectRating.create(:project => @project)
      end

      @rating = params[:rating]
      @current_rating.rating = @rating

      if @current_rating.save!
        @project.rated_at = Time.now
        @project.admin_rating = @rating
        @project.save!
      end

      @body = params[:body]

      if !@body.blank?
        @current_comment = ProjectComment.create
        @current_comment.body = @body
        @current_comment.user_id = @u.id
        @current_comment.project_id = @project_id
        @current_comment.save!
      end
      
      flash[:positive] = "Project Updated!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id

    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error updating project!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id
    end
  end

  def set_selected_tab
    @selected_tab_name = "rate_projects"
  end
  
end
