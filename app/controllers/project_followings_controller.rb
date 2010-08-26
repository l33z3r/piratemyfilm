class ProjectFollowingsController < ApplicationController

  before_filter :load_project

  def create
    @following = ProjectFollowing.find_by_user_id_and_project_id(@u, @project)

    if !@following
      @project_following = ProjectFollowing.create( :user => @u, :project => @project)
      flash[:positive] = "You are now following this project"
    else
      flash[:error] = "You are already following this project"
    end

    redirect_to project_path(@project)
  end

  def unfollow
    @following = ProjectFollowing.find_by_user_id_and_project_id(@u, @project)

    if @following
      @following.destroy
      flash[:positive] = "You are no longer following this project"
    else
      flash[:error] = "You not following this project"
    end

    redirect_to project_path(@project)
  end

  private

  def allow_to
    super :admin, :all => true
    super :user, :only => [:create, :destroy]
  end

  def load_project
    begin
      @project = Project.find(params[:project_id])
      logger.debug "Found project #{@project}"
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

end
