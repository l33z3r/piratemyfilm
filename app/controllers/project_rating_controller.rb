class ProjectRatingController < ApplicationController

  def rate
    begin
      @project_id = params[:project_id]
      @project = Project.find(@project_id)
          
      @my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project_id, @u.id)

      if !@my_project_rating
        @current_project_rating = ProjectRating.find_by_project_id @project_id

        if !@current_project_rating
          @current_project_rating = ProjectRating.create(:project => @project, :average_rating => 0)
        end

        #Get all project rating historys
        @project_rating_histories = ProjectRatingHistory.find_all_by_project_id @project_id
        
        @rating = params[:rating].to_f

        #update the running average
        @alpha = 1.0/(@project_rating_histories.size + 1)
        @current_sample = @rating
        @current_avg = @current_project_rating.average_rating

        #formula for updating running avg
        @new_avg = ((1 - @alpha) * @current_avg) + (@alpha * @current_sample)
        
        @current_project_rating.average_rating = @new_avg
        @current_project_rating.save!

        #add the new sample
        ProjectRatingHistory.create(:project => @project, :user => @u, :rating => @rating)
        
        flash[:positive] = "Project Rated!"
      else
        flash[:negative] = "You have already rated this project!"
      end

      redirect_to :controller => "projects", :action => "show", :id => @project_id
    rescue ActiveRecord::RecordInvalid
      flash[:negative] = "Error rating project!"
      redirect_to :controller => "projects", :action => "show", :id => @project_id
    end
  end

  protected

  def allow_to
    super :user, :all => true
  end

end
