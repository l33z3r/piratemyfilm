class Admin::ProjectRatingController < Admin::AdminController

  def index
    @projects = Project.find(:all, :conditions => "rated_at is null and is_deleted = 0", :order=>"created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 8
  end

  def rate
    begin
      @project_id = params[:project_id]
      
      @current_rating = AdminProjectRating.find_by_project_id @project_id

      @current_comment = ProjectComment.find_by_project_id(@project_id)

      if !@current_rating
        @project = Project.find(@project_id)
        @current_rating = AdminProjectRating.create(:project => @project)
      end

      unless @current_comment
        @current_comment = ProjectComment.create
      end

      @rating = params[:rating]
      @current_rating.rating = @rating

      if @current_rating.save!
        @project = Project.find_by_id(@project_id)
        @project.rated_at = Time.now
        @project.admin_rating = @rating
        @project.save!
      end

      @body = params[:body]
      @current_comment.body = @body
      @current_comment.user_id = @u.id
      @current_comment.project_id = @project_id
      @current_comment.save!

      flash[:positive] = "Project Rated!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id

    rescue ActiveRecord::RecordInvalid
      flash[:negative] = "Error rating project!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id
    end
  end

  def set_selected_tab
    @selected_tab_name = "new_projects"
  end
  
end
