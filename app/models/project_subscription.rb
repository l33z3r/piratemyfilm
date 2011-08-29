class ProjectSubscription < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :project
  belongs_to :subscription_payment
  
  def payment_status
    return "N/A" if subscription_payment.nil?
    subscription_payment.status
  end

  def payment_window_id
    if subscription_payment
      return subscription_payment.payment_window.id
    else
      return nil
    end
  end

  def in_active_window?
    if subscription_payment
      return subscription_payment.payment_window.open?
    else
      return nil
    end
  end

  private

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
      @number_projects_subscribed_to = user.number_non_funded_projects_subscribed_to
      @max_overall_project_subscriptions = user.membership_type.pc_project_limit
      @max_project_subscription_reached = @number_projects_subscribed_to >= @max_overall_project_subscriptions
    end

    @max_project_subscription_reached
  end

  def self.calculate_amount project_subscriptions
    @num_shares = 0

    #sum up all the shares in project_subscriptions
    project_subscriptions.each do |ps|
      @num_shares += ps.amount
    end

    @num_shares
  end

  def self.calculate_outstanding_amount project_subscriptions
    @num_shares = 0

    #sum up all the outstanding shares in project_subscriptions
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

  def self.share_queue project
    @subscriptions = find_all_by_project_id(project, :order => "created_at, id", :include => {:user => {:membership => :membership_type}})
    @subscriptions = apply_sorting_rules(@subscriptions)
    @subscriptions
  end

  #get the end of the queue that has not been assigned a payment yet
  def self.share_queue_pending project
    @subscriptions = find_all_by_project_id(project, :order => "created_at, id")
    @subscriptions = apply_sorting_rules(@subscriptions)

    #trim off the start of the queue for subscriptions that have been assigned a paymentd
    @subscriptions = @subscriptions.reject(&:subscription_payment_id)

    @subscriptions
  end

  #get the end of the queue that has not been assigned a payment yet and
  #that belong to the pmf fund
  def self.share_queue_pending_pmf_fund project
    @subscriptions = find_all_by_project_id(project, :order => "created_at, id")
    @subscriptions = apply_sorting_rules(@subscriptions)

    #trim off the start of the queue for subscriptions that have been assigned a paymentd
    @subscriptions = @subscriptions.reject(&:subscription_payment_id)

    #take out any shares that are not belonging to pmf fund
    @subscriptions = @subscriptions.reject do |sub|
      sub.user_id != Profile.find(PMF_FUND_ACCOUNT_ID).user.id
    end

    @subscriptions
  end

  def self.update_share_queue project
    logger.debug "UPDATING SHARE QUEUE FOR PROJECT #{project.id}"

    if project.in_payment_phases?
      logger.debug "Will not update share queue for project that is in payment"
      return
    end

    ProjectSubscription.transaction do
      project.reload

      @subscriptions = find_all_by_project_id(project, :order => "created_at, id", :lock => true)
      @subscriptions = apply_sorting_rules(@subscriptions)

      @subscriptions = @subscriptions ? @subscriptions : {}

      @shares_available = project.total_copies

      @share_sum = 0
      @stop_index = 0

      @reached_outstanding = false

      @subscriptions.each do |ps|
        if !@reached_outstanding
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

            @reached_outstanding = true
          end

        else
          ps.outstanding = true
          ps.save!
        end
      end
      
    end
  end

  #this makes the share queue in memory
  def self.apply_sorting_rules(subscriptions)
    @subscriptions = subscriptions

    #pmf fund subs go to back of queue
    @subscriptions = sort_pmf_fund_subs(@subscriptions)

    #maxriot goes to front of queue
    @subscriptions = sort_maxriot_subs(@subscriptions)

    #some accounts can skip the queue
    @subscriptions = apply_account_skipping(@subscriptions)

    @subscriptions
  end

  def self.sort_pmf_fund_subs(subscriptions)
    @subscriptions = subscriptions
    
    #must bump all pmf fund shares to the back of the queue
    #we know that pmf fund shares have a creation date of 0
    @temp_subscriptions = []
    @temp_pmf_fund_subs = []

    @subscriptions.each do |sub|
      if sub.user_id == PMF_FUND_USER_ID
        @temp_pmf_fund_subs << sub
      else
        @temp_subscriptions << sub
      end
    end

    #now join the two arrays
    @subscriptions = @temp_subscriptions + @temp_pmf_fund_subs
    @subscriptions
  end

  def self.sort_maxriot_subs(subscriptions)
    #for now we want the maxriot account to skip the queue
    @maxriot_user_id = MAXRIOT_USER_ID

    @subscriptions = subscriptions

    #must bump all pmf fund shares to the back of the queue
    #we know that pmf fund shares have a creation date of 0
    @temp_subscriptions = []
    @temp_maxriot_subs = []

    @subscriptions.each do |sub|
      if sub.user_id == @maxriot_user_id
        @temp_maxriot_subs << sub
      else
        @temp_subscriptions << sub
      end
    end

    #now join the two arrays
    @subscriptions = @temp_maxriot_subs + @temp_subscriptions
    @subscriptions
  end

  def self.apply_account_skipping(subscriptions)
    #for now we want the maxriot account to skip the queue
    @maxriot_user_id = MAXRIOT_USER_ID

    @temp_maxriot_subs = []
    @temp_black_pearl_subs = []
    @temp_platinum_subs = []
    @temp_gold_subs = []
    @temp_basic_subs = []
    @temp_pmf_fund_subs = []

    @subscriptions = subscriptions
    
    @subscriptions.each do |sub|
      if sub.user_id == @maxriot_user_id
        @temp_maxriot_subs << sub
      elsif sub.user_id == PMF_FUND_USER_ID
        @temp_pmf_fund_subs << sub
      elsif sub.user.membership.membership_type_id == MembershipType.find_by_name("Black Pearl").id
        @temp_black_pearl_subs << sub
      elsif sub.user.membership.membership_type_id == MembershipType.find_by_name("Platinum").id
        @temp_platinum_subs << sub
      elsif sub.user.membership.membership_type_id == MembershipType.find_by_name("Gold").id
        @temp_gold_subs << sub
      elsif sub.user.membership.membership_type_id == MembershipType.find_by_name("Basic").id
        @temp_basic_subs << sub
      end
    end

    #join all arrays
    @subscriptions = @temp_maxriot_subs + @temp_black_pearl_subs + @temp_platinum_subs + @temp_gold_subs + @temp_basic_subs + @temp_pmf_fund_subs
    @subscriptions
  end

  def self.load_subscriptions user, project
    @subscriptions = find_all_by_user_id_and_project_id(user, project, :order => "created_at DESC, id DESC")
    @subscriptions = @subscriptions ? @subscriptions.to_a : {}
  end

  def self.load_non_outstanding_subscriptions user, project
    @subscriptions = find_all_by_user_id_and_project_id(user, project, :conditions => "outstanding is false", :order => "created_at DESC, id DESC")
    @subscriptions = @subscriptions ? @subscriptions.to_a : {}
  end

end

# == Schema Information
#
# Table name: project_subscriptions
#
#  id                      :integer(4)      not null, primary key
#  project_id              :integer(4)
#  user_id                 :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#  amount                  :integer(10)     default(1)
#  outstanding             :boolean(1)      default(FALSE)
#  subscription_payment_id :integer(4)
#

