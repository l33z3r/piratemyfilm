class ProjectRatingController < ApplicationController

  def rate
    begin
      @project_id = params[:project_id]
      @project = Project.find(@project_id)
          
      @my_project_rating = ProjectRatingHistory.find_by_project_id_and_user_id(@project_id, @u.id, :order => "created_at DESC", :limit => "1")

      @beginning_of_day = Time.now.beginning_of_day

      if @my_project_rating && @my_project_rating.created_at > @beginning_of_day
        flash[:error] = "You have already rated this project today!"
        redirect_to :controller => "projects", :action => "show", :id => @project_id and return
      end

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

      @project.member_rating = @new_avg
      @project.save!

      #add the new sample
      ProjectRatingHistory.create(:project => @project, :user => @u,
        :project_rating => @current_project_rating, :rating => @rating)
        
      flash[:positive] = "Project Rated!"

      redirect_to :controller => "projects", :action => "show", :id => @project_id
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error rating project!"
      redirect_to :controller => "projects", :action => "show", :id => @project_id
    end
  end

  protected

  def allow_to
    super :user, :all => true
  end

end
