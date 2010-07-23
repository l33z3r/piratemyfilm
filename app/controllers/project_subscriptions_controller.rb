class ProjectSubscriptionsController < ApplicationController

  before_filter :load_project, :get_project_subscription

  cache_sweeper :project_sweeper, :only => [:create, :destroy]

  def create
    begin            

      #check that user does not own this project
      if !allowed_reserve_shares
        flash[:error] = "As the owner of this project, you cannot reserve shares!"
        redirect_to project_path(@project) and return
      end
      
      #a user can only have pc_limit pcs per project
      @max_subscription_reached == false

      @max_subscription = @u.membership_type.pc_limit
      unless @max_subscription == -1
        @max_subscription_reached = @project_subscription && @project_subscription.amount >= @max_subscription
      end

      #a user can have a pcs in a maximum of pc_project_limit projects
      @max_project_subscription_reached = false

      if !@project_subscription
        @number_projects_subscribed_to = @u.project_subscriptions.size
        @max_overall_project_subscriptions = @u.membership_type.pc_project_limit
        unless @max_overall_project_subscriptions == -1
          @max_project_subscription_reached = @number_projects_subscribed_to >= @max_overall_project_subscriptions
        end
      end

      if !@project_subscription.nil?
        if @max_subscription_reached or @max_project_subscription_reached
          flash[:error] = "You have reached the maximum shares for this project"
        else
          @project_subscription.amount += 1
          @project_subscription.save!
        end
      else
        @project_subscription = ProjectSubscription.create( :user => @u, :project => @project, :amount => 1 )
      end

      flash[:notice] = "Share reserved!"
      
    rescue ActiveRecord::RecordInvalid => ex
      logger.error "Error reserving share! #{ex.message}"
      flash[:error] = "Error reserving share!"
    end
    
    redirect_to project_path(@project)    
  end

  def destroy
    begin            
      
      if @project_subscription.nil?       
        flash[:error] = "You do not have any shares in this project to cancel!"
        redirect_to project_path(@project) and return
      else
        if @project_subscription.amount > 1
          @project_subscription.amount -= 1
          @project_subscription.save!
        else
          @project_subscription.destroy
        end

        flash[:notice] = "Share canceled!"
      end
      
    rescue ActiveRecord::RecordInvalid => ex
      logger.error "Error canceling share! #{ex.message}"
      flash[:error] = "Error canceling share in this project"
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

  def allow_to
    super :all, :all=>true
  end
  
end
