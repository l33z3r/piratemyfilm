class ProjectSubscriptionsController < ApplicationController
  
  before_filter :load_project, :get_project_subscription
  after_filter :upate_percent_funded, :only => [:create, :destroy]
  
  def create
    begin            

      #check that user does not own this project
      if @project.owner == @u
        flash[:error] = "As the owner of this project, you cannot buy any premium copies of it!"
        redirect_to project_path(@project) and return
      end
      
      if @project.downloads_available <= 0
        flash[:error] = "There are no more premium copies available for reservation"
        redirect_to project_path(@project) and return
      end
      
      @max_subscription = @u.membership_type.pc_limit_per_project
      @max_subscription_reached = @project_subscription && @project_subscription.amount >= @max_subscription

      if !@project_subscription.nil?
        
        if @max_subscription_reached
          flash[:positive] = "You have reached the maximum premium copies of this project"
        else
          @project_subscription.amount += 1
          @project_subscription.save!
        
          flash[:positive] = "You now have #{@project_subscription.amount} premium copies of this project"
        end
                
        redirect_to project_path(@project) and return
      end
      
      @project_subscription = ProjectSubscription.create( :user => @u, :project => @project, :amount => 1 )      
      
      flash[:positive] = "You have reserved a premium copy of this project!"
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error reserving premium copy".x
    end    
    redirect_to project_path(@project)    
  end

  def destroy
    begin            
      
      if @project_subscription.nil?       
        flash[:negative] = "You do not have any premium copies of this project to cancel!"
        redirect_to project_path(@project) and return
        
      else
        if @project_subscription.amount > 1
          
          @project_subscription.amount -= 1
          @project_subscription.save!
        
          redirect_to project_path(@project) and return
        else
          @project_subscription.destroy
        end

        flash[:positive] = "You have canceled a premium copy of this project!"
      end
      
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error canceling premium copy of this project"
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
