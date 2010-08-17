# == Schema Information
# Schema version: 20100814145209
#
# Table name: project_subscriptions
#
#  id          :integer(4)    not null, primary key
#  project_id  :integer(4)    
#  user_id     :integer(4)    
#  created_at  :datetime      
#  updated_at  :datetime      
#  amount      :integer(10)   default(1)
#  outstanding :boolean(1)    
#

class ProjectSubscription < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :project

  after_save :update_project_funding
  after_destroy :update_project_funding

  private

  def update_project_funding
    project.update_funding_and_estimates
  end

  #returns the number of shares the user can take from this project
  def self.num_shares_allowed user, project
    @project_subscriptions = self.load_subscriptions(user, project)

    @max_subscription = user.membership_type.pc_limit

    @subscriptions_amount = self.calculate_amount(@project_subscriptions)

    @num_shares_allowed = @max_subscription - @subscriptions_amount

    @num_shares_allowed
  end

  def self.pc_limit_reached user, project
    @project_subscriptions = self.load_subscriptions(user, project)

    @max_subscription = user.membership_type.pc_limit

    @num_shares = self.calculate_amount @project_subscriptions

    @max_subscription_reached = @num_shares >= @max_subscription

    @max_subscription_reached
  end

  def self.pc_project_limit_reached user, project
    @project_subscriptions = self.load_subscriptions(user, project)

    @max_project_subscription_reached = false

    if @project_subscriptions.size == 0
      @number_projects_subscribed_to = user.number_projects_subscribed_to
      @max_overall_project_subscriptions = user.membership_type.pc_project_limit
      @max_project_subscription_reached = @number_projects_subscribed_to >= @max_overall_project_subscriptions
    end

    @max_project_subscription_reached
  end

  def self.calculate_amount project_subscriptions
    @num_shares = 0

    #sum up all the shares the user has in this project
    project_subscriptions.each do |ps|
      @num_shares += ps.amount
    end

    @num_shares
  end

  def self.calculate_outstanding_amount project_subscriptions
    @num_shares = 0

    #sum up all the shares the user has in this project
    project_subscriptions.each do |ps|
      if ps.outstanding
        @num_shares += ps.amount
      end
    end

    @num_shares
  end

  def self.cancel_shares_for_project project_subscriptions, num_shares
    @num_left_to_cancel = num_shares

    project_subscriptions.each do |ps|
      break if @num_left_to_cancel == 0

      @current_amount = ps.amount

      if @current_amount <= @num_left_to_cancel
        @num_left_to_cancel -= @current_amount
        ps.destroy
      else
        ps.amount -= @num_left_to_cancel
        ps.save
        @num_left_to_cancel = 0
      end
    end
    
  end

  def self.update_share_queue project
    project.reload
    
    @subscriptions_find = find_all_by_project_id(project, :order => "created_at, id")
    @subscriptions = @subscriptions_find ? @subscriptions_find.to_a : {}

    @shares_available = project.total_copies

    @share_sum = 0
    @stop_index = 0

    @subscriptions.each_with_index do |ps, index|
      @share_sum += ps.amount

      #any share below @shares_available will be marked as non-outstanding
      if ps.outstanding
        ps.outstanding = false
        ps.save!
      end

      logger.info("Share sum is #{@share_sum}, Shares Available: #{@shares_available}")

      if @share_sum > @shares_available
        #we may have to split the current block of shares
        if (@share_sum - ps.amount) < @shares_available
          #create non outstanding block
          ps.amount = ps.amount - (@share_sum - @shares_available)
          ps.outstanding = false
          ps.save!

          #create outstanding shares
          ProjectSubscription.create( :user => ps.user,
            :project => ps.project, :amount => @share_sum - @shares_available,
            :outstanding => true )

        else
          #the share block is lined up exactly with @shares_available
          ps.outstanding = true
          ps.save!
        end

        @stop_index = index + 1
        #now break out of this loop to set all outstanding shares as outstanding
        break

      end
    end

    logger.info "Marking #{(@subscriptions.length-1) - @stop_index} shares as outstanding"
    logger.info "subscriptions length: #{@subscriptions.length}"

    if @stop_index > 0
      #mark all other shares as outstanding
      for i in (@stop_index..(@subscriptions.length-1))
        logger.info "Marking #{@current_ps.id}"
        @current_ps = @subscriptions[i]
        @current_ps.outstanding = true
        @current_ps.save!
      end
    end

  end

  def self.load_subscriptions user, project
    @subscriptions = find_all_by_user_id_and_project_id(user, project, :order => "created_at DESC, id DESC")
    @subscriptions = @subscriptions ? @subscriptions.to_a : {}
  end

end
