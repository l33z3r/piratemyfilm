class Admin::ProjectRatingController < ApplicationController

  def rate
    begin
      @project_id = params[:project_id]
      
      @current_rating = AdminProjectRating.find_by_project_id @project_id

      if !@current_rating
        @project = Project.find(@project_id)
        @current_rating = AdminProjectRating.create(:project => @project)
      end

      @rating = params[:rating]
      @current_rating.rating = @rating
      @current_rating.save!

      flash[:positive] = "Project Rated!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id

    rescue ActiveRecord::RecordInvalid
      flash[:negative] = "Error rating project!"
      redirect_to :controller => "/projects", :action => "show", :id => @project_id
    end
  end

  private

  def allow_to
    super :admin, :all => true
  end
  
end
