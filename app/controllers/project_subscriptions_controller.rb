class ProjectSubscriptionsController < ApplicationController
  
  before_filter :load_project, :get_project_subscription
  
  def create
    begin            
      
      if !@project_subscription.nil?
        flash[:negative] = "You have already subscribed to this project"
        redirect_to project_path(@project) and return
      end
      
      @project_subscription = ProjectSubscription.create( :user => @u, :project => @project )      
      flash[:positive] = "You have subscribed to this project"
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error subscribing".x
    end    
    redirect_to project_path(@project)    
  end

  def destroy
    begin            
      
      if @project_subscription.nil?
        flash[:negative] = "You are not subscribed to this project"
        redirect_to project_path(@project) and return
      end
      
      @project_subscription.destroy
      flash[:positive] = "You have un-subscribed to this project"
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error un-subscribing from this project"
    end    
    redirect_to project_path(@project)
  end

  protected
  
  def allow_to
    super :admin, :all => true
    super :user, :only => [:create, :destroy]
  end 
  
  def get_project_subscription
    @project_subscription = ProjectSubscription.find_by_user_id_and_project_id(@u, @project)
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
