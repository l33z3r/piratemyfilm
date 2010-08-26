class Admin::ProjectRatingController < Admin::AdminController

  def rate
    begin
      @project_id = params[:project_id]
      @project = Project.find_by_id(@project_id)

      @rating = params[:rating]

      if @project.admin_rating != AdminProjectRating.symbol_for_rating(@rating.to_i)

        @current_rating = AdminProjectRating.create(:project => @project)
      
        @current_rating.rating = @rating

        if @current_rating.save!
          @project.rated_at = Time.now
          @project.admin_rating = @rating
          @project.save!
        end
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
