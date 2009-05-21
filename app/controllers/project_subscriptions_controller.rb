class ProjectSubscriptionsController < ApplicationController
  
  before_filter :load_project, :get_project_subscription
  after_filter :upate_percent_funded, :only => [:create, :destroy]
  
  def create
    begin            

      @max_subscription = ProjectSubscription.max_subscriptions
      @max_subscription_reached = @project_subscription && @project_subscription.amount == @max_subscription

      if !@project_subscription.nil?
        
        if @max_subscription_reached
          flash[:positive] = "You have reached the maximum prebuys for this project"
        else
          @project_subscription.amount += 1
          @project_subscription.save!
        
          flash[:positive] = "You have now got #{@project_subscription.amount} subscriptions to this project"  
        end
                
        redirect_to project_path(@project) and return
      end
      
      @project_subscription = ProjectSubscription.create( :user => @u, :project => @project, :amount => 1 )      
      
      flash[:positive] = "You have reserved a producer copy for this project!"
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
        
      else
        if @project_subscription.amount > 1
          
          @project_subscription.amount -= 1
          @project_subscription.save!
        
          redirect_to project_path(@project) and return
        else
          @project_subscription.destroy
        end

        flash[:positive] = "You have canceled a producer copy for this project!"
      end
      
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
  
  def upate_percent_funded
    @project.update_funding
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
