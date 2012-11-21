class Project < ActiveRecord::Base    

  @@PROJECT_STATUSES = ["Pre Production", "In Production", "Post Production",
    "Ransom", "Finishing Funds", "Trailer"]

  @@PROJECT_PAYMENT_STATUSES = ["In Payment", "Finished Payment"]
  
  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many :project_subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :project_subscriptions, :source => :user,
    :order => "project_subscriptions.created_at", :group => "id"

  has_many :project_change_info_one_days, :dependent => :destroy, :order => "created_at DESC"
  
  has_many :blogs, :dependent => :destroy
  has_many :project_flaggings, :dependent => :destroy
  
  belongs_to :genre, :foreign_key=>'genre_id'

  attr_protected :symbol

  validates_presence_of :owner_id, :title, :status
  validates_presence_of :ipo_price, :genre_id, :capital_required
  
  validates_inclusion_of :status, :in => @@PROJECT_STATUSES

  validates_uniqueness_of :title
  validates_uniqueness_of :symbol, :allow_nil => true, :allow_blank => true

  #description will be the logline of the project
  #we are limiting it to 140 characters so that it is like twitter
  validates_length_of :description, :within => 0..140, :allow_blank => true
  validates_length_of :title, :minimum => 5
  
  validates_numericality_of :capital_required, :ipo_price, :project_length, :weeks_to_finish, :allow_nil => true
  validates_numericality_of :capital_recycled_percent, :producer_fee_percent, :allow_nil => true
  validates_numericality_of :share_percent_ads, :allow_nil => true

  validates_filesize_of :icon, {:in => 0.kilobytes..1.megabyte, :message => "Your Project Image must be less than 1 megabyte"}

  validate_on_create :funding_limit_not_exceeded, :min_funding_limit_passed
  validate_on_update :funding_limit_not_exceeded, :min_funding_limit_passed

  validates_format_of :web_address, :with => URI::regexp(%w(http https)), :allow_blank => true
  
  #  validates_format_of :paypal_email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true, :message => "Invalid email address."
  validates_format_of :bitpay_email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true, :message => "Invalid email address."
  
  acts_as_ferret :fields => [ :title, :synopsis, :description, 
    :user_login, :user_full_name, :director, :writer, :exec_producer,
    :director_photography, :editor ], :remote => true

  #note that we duplicate the following data as we need it to sort and order projects on the browse page
  #this makes the queries run faster
  has_one :project_rating, :dependent => :destroy
  
  has_one :admin_project_rating, :order => "created_at DESC", :dependent => :destroy
  has_many :admin_project_ratings, :order => "created_at DESC", :dependent => :destroy
  has_many :pmf_fund_subscription_histories, :dependent => :destroy

  has_many :subscription_payments, :order => "created_at"
  has_many :completed_payments, :class_name => 'SubscriptionPayment', :foreign_key => 'project_id', :conditions => "status = 'Paid'", :order => "created_at"
  has_many :defaulted_payments, :class_name => 'SubscriptionPayment', :foreign_key => 'project_id', :conditions => "status = 'Defaulted'", :order => "created_at"
  
  has_many :payment_windows

  has_one :pmf_share_buyout
  
  has_many :project_comments, :dependent => :destroy
  has_one :latest_project_comment, :class_name => "ProjectComment", :order => "created_at DESC"

  has_many :project_user_talents
  has_many :user_talents, :through => :project_user_talents
  
  has_many :project_followings
  
  has_many :actor_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'actor'", :dependent => :destroy
  
  has_many :director_project_talents, :class_name => "ProjectUserTalent", 
    :include => "user_talent", :conditions => "user_talents.talent_type = 'director'", :dependent => :destroy
  
  has_many :writer_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'writer'", :dependent => :destroy
  
  has_many :exec_producer_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'exec_producer'", :dependent => :destroy
  
  has_many :director_photography_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'director_photography'", :dependent => :destroy
  
  has_many :editor_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'editor'", :dependent => :destroy
  
  has_many :producer_project_talents, :class_name => "ProjectUserTalent",
    :include => "user_talent", :conditions => "user_talents.talent_type = 'producer'", :dependent => :destroy

  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  file_column :main_video

  after_create :generate_symbol
  
  def youtube_vid_id_stripped
    #split the url to get the video id
    @start = youtube_vid_id.rindex("v=")
    if @start
      @start += 2
      @stop = youtube_vid_id.index("&", @start)
      @stop = youtube_vid_id.length if !@stop
      @vid_id = youtube_vid_id[@start..@stop - 1]
    else
      @vid_id = nil
    end

    @vid_id
  end
  
  def youtube_vid_id=(new_link)
    write_attribute("youtube_vid_id", new_link)
  end

  #find projects that have been given initial rating and are not deleted
  def self.find_all_public(*args)

    #TODO: use with_scope

    options = args[0] ? args[0] : {}

    if options[:conditions]
      options[:conditions] << sanitize_sql(' AND symbol IS NOT NULL')
    else
      options[:conditions] = sanitize_sql('symbol IS NOT NULL')
    end

    options[:conditions] << sanitize_sql(' AND is_deleted = 0 ')

    @projects = self.find(:all, options)

    @projects
    
  end
  
  def self.find_first_public(*args) 
    @projects = Project.find_all_public(*args)
    
    @project = nil
    
    if @projects.size > 0
      @project = @projects.first
    end
    
    @project
  end

  def self.find_single_public(id)

    @project = self.find(id)
    
    if @project.symbol && !@project.is_deleted
      return @project
    else
      return nil
    end
  end
  
  def self.search query = '', options = {}
    logger.debug "Searching for projects with query #{query}"
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = find_by_contents q, {:limit=>:all}, {:conditions => 'symbol IS NOT NULL and is_deleted = 0'}
    logger.debug arr.inspect
    arr
  end   

  def self.statuses
    @@PROJECT_STATUSES
  end

  #overide save to perform updating of estimates
  def save!
    super
    logger.debug "overriden save called!"
    update_vars
    super
  end

  def save_without_validating
    save(false)
    logger.debug "overriden non validating save called!"
    update_vars
    save(false)
  end

  def update_vars
    #must update the share queue first
    ProjectSubscription.update_share_queue self
    set_defaults
    update_recycled_percent
    update_pmf_fund_investment
    update_funding
    update_estimates
  end

  def set_defaults
    self.producer_fee_percent = 0 if !self.producer_fee_percent
  end

  #this is simply here for completeness...
  def update_funding_and_estimates
    self.save_without_validating
  end

  #funding does not take into account the pmf fund investment
  def update_funding
    logger.debug "Updating percent funded"
    @total_copies = total_copies
    @downloads_reserved = project_subscriptions.collect { |s| s.amount }.sum #- self.pmf_fund_investment_share_amount_incl_outstanding
    self.downloads_reserved = @downloads_reserved
    self.downloads_available = @total_copies - self.downloads_reserved

    @new_funding_percentage = ((downloads_reserved * 100) / @total_copies).ceil

    if @new_funding_percentage >= 100 and !yellow_light
      Notification.deliver_fully_funded_notification self
      
      #do yellow light 
      self.yellow_light = Time.now
      save(false)

      Notification.deliver_yellow_light_notification self
    
      # are we in frozen yellow light?
      if self.frozen_yellow?
        PaymentsMailer.deliver_bitpay_email_prompt self
      end
    elsif percent_funded < 90 and @new_funding_percentage >= 90
      Notification.deliver_90_percent_funded_notification self
    end

    self.percent_funded = @new_funding_percentage

    #update percentage of bad shares
    @bad_share_count = 0

    project_subscriptions.each do |ps|
      #next if ps.user.id == Profile.find(PMF_FUND_ACCOUNT_ID).user.id
      @bad_share_count += ps.amount if ps.user.warn_points > 0
    end

    self.percent_bad_shares = @downloads_reserved > 0 ? (@bad_share_count * 100) / @downloads_reserved : 0
  end

  def update_estimates
    logger.debug "Updating Estimates!"

    @revenue_from_assumptions = 1000

    @producer_and_shareholder_take = (self.share_percent_ads_producer/100.0) * @revenue_from_assumptions
    self.fund_dividend = (self.capital_recycled_percent/100.0) * @revenue_from_assumptions
    
    @shareholder_final_percentage_take = self.share_percent_ads
    @producer_final_percentage_take = 100 - self.share_percent_ads

    @shareholder_final_take_full = (@shareholder_final_percentage_take/100.0) * @producer_and_shareholder_take
    self.shareholder_dividend = @shareholder_final_take_full/total_copies
    self.producer_dividend = (@producer_final_percentage_take/100.0) * @producer_and_shareholder_take
  end

  def update_pmf_fund_investment
    logger.debug "Updating PMF Fund Investment!"

    @pmf_fund_user = Profile.find(PMF_FUND_ACCOUNT_ID).user

    @subscriptions = ProjectSubscription.load_non_outstanding_subscriptions @pmf_fund_user, self
    @subscription_amount = ProjectSubscription.calculate_amount @subscriptions

    if @subscription_amount >= 0
      self.pmf_fund_investment_share_amount = @subscription_amount
      self.pmf_fund_investment_percentage = (@subscription_amount/total_copies) * 100
    end
  end

  def pmf_fund_investment_share_amount_incl_outstanding
    @pmf_fund_user = Profile.find(PMF_FUND_ACCOUNT_ID).user

    @subscriptions = ProjectSubscription.load_subscriptions @pmf_fund_user, self
    @subscription_amount = ProjectSubscription.calculate_amount @subscriptions
  end

  def pmf_fund_investment_total
    self.pmf_fund_investment_share_amount * self.ipo_price
  end

  def percent_funded_with_pmf_fund_non_outstanding
    percent_funded + pmf_fund_investment_percentage
  end
  
  def percent_move_since_last_change_info
    if project_change_info_one_days.first
      @last_night_share_amount = project_change_info_one_days.first.share_amount
    else 
      @last_night_share_amount = 0
    end
    
    @now_share_amount = ProjectSubscription.calculate_amount project_subscriptions
    
    @change_amount = @now_share_amount - @last_night_share_amount
    
    if @last_night_share_amount == 0
      if @change_amount == 0
        @change_percent = 0
      else
        @change_percent = 100
      end
    else
      @change_percent = ((@change_amount.to_f/@last_night_share_amount) * 100).ceil
    end
    
    @change_percent
  end

  def user_rating
    @user_project_rating = ProjectRating.find_by_project_id id
    @user_project_rating ? @user_project_rating.rating_symbol : ProjectRating.ratings_map[1]
  end

  def admin_rating
    admin_project_rating ? admin_project_rating.rating_symbol : AdminProjectRating.ratings_map[1]
  end

  def current_funds
    self.downloads_reserved * self.ipo_price
  end

  def funds_needed
    self.capital_required - self.current_funds
  end

  def total_copies
    capital_required / ipo_price
  end

  #only allow update of capital_required if project not in payment
  def capital_required=(newval)
    super unless in_payment?
  end

  def capital_required
    if !super
      return 0
    end

    super
  end

  def capital_recycled_percent
    if !super
      return 0
    end

    super
  end

  def ipo_price
    if !super
      return 0
    end

    super
  end

  def share_percent_ads
    if !super
      return 0
    end
    
    super
  end

  def share_percent_ads_producer
    if !super
      return 0
    end

    super
  end

  def budget_reached?
    self.percent_funded >= 100
  end

  def budget_reached_include_pmf?
    self.percent_funded_with_pmf_fund_non_outstanding >= 100
  end

  def delete
    self.is_deleted = true
    self.member_rating = 0
    self.deleted_at = Time.now
    self.save_without_validating
  end

  def restore
    self.is_deleted = false
    self.deleted_at = nil
    self.save_without_validating
  end

  @@filter_params_map = {
    1 => "View Projects By", 2 => "Frozen Yellow Light", 3 => "Yellow Light", 4 => "Green Light", 5 => "% Funded All", 
    #    6 => "% Funded - Pre Production", 7 => "% Funded - In Production", 
    #    8 => "% Funded - Post Production", 9 => "% Funded - Finishing Funds",
    #    10 => "% Funded - Trailer", 
    11 => "Funds Needed", 12 => "Funds Reserved",
    13 => "PMF Fund Rating", 14 => "Member Rating", 15 => "Newest", 16 => "Oldest",
    #17 => "Producer Dividend", 18 => "Shareholder Dividend", 19 => "PMF Fund Dividend",
    #20 => "% PMF Fund Shares",
    #21 => "No. PMF Fund Shares",
    #22 => "In Payment", 
    23 => "Fully Funded",
    #24 => "In Release", 
    25 => "% Move Up", 26 => "% Move Down"
  }

  def self.get_filter_sql filter_param

    #filter out all the projects that are finished payment
    @payment_status_filter = "(project_payment_status is null or project_payment_status != 'Finished Payment')"
    
    #filter out all projects that are green lit
    @green_light_filter = " green_light is null"
    @yellow_light_filter = " yellow_light is null"
    
    case filter_param.to_s
    when "2" then return "project_payment_status is null and yellow_light is not null and (bitpay_email is null or length(bitpay_email) = 0)"
    when "3" then return "project_payment_status is null and yellow_light is not null and (bitpay_email is not null and length(bitpay_email) > 0)"
    when "4" then return "green_light is NOT NULL and project_payment_status != 'Finished Payment'"
    when "5" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "6" then return "status = \"Pre Production\" and #{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "7" then return "status = \"In Production\" and #{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "8" then return "status = \"Post Production\" and #{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "9" then return "status = \"Finishing Funds\" and #{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "10" then return "genre_id = #{Genre.find_by_title("Trailer").id} and #{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "11" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "12" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "13" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "14" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "15" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "16" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "17" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "18" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "19" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "20" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "21" then return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    when "22" then return "project_payment_status = 'In Payment'"
    when "23" then return "project_payment_status = 'Finished Payment'"
    when "24" then return "project_payment_status = 'Finished Payment' and status = 'In Release'"
    when "25" then return "#{@payment_status_filter}"
    when "26" then return "#{@payment_status_filter}"    
    else return "#{@payment_status_filter} and #{@green_light_filter} and #{@yellow_light_filter}"
    end
  end

  def self.get_order_sql filter_param
    case filter_param.to_s
    when "2" then return "yellow_light DESC"
    when "3" then return "yellow_light DESC"
    when "4" then return "green_light DESC"        
    when "5" then return "percent_funded DESC"
    when "6" then return "percent_funded DESC"
    when "7" then return "percent_funded DESC"
    when "8" then return "percent_funded DESC"
    when "9" then return "percent_funded DESC"
    when "10" then return "percent_funded DESC"
    when "11" then return "capital_required DESC"
    when "12" then return "(downloads_reserved * ipo_price) DESC"
    when "13" then return "admin_rating DESC"
    when "14" then return "member_rating DESC"
    when "15" then return "created_at DESC"
    when "16" then return "created_at ASC"
      #    when "17" then return "producer_dividend DESC"
      #    when "18" then return "shareholder_dividend DESC"
      #    when "19" then return "fund_dividend DESC"
      #    when "20" then return "pmf_fund_investment_percentage DESC"
    when "21" then return "pmf_fund_investment_share_amount DESC"
    when "22" then return "green_light DESC"
    when "23" then return "fully_funded_time DESC"
    when "24" then return "fully_funded_time DESC"
    when "25" then return "daily_percent_move DESC"
    when "26" then return "daily_percent_move"    
    else return "created_at DESC"
    end
  end

  def self.filter_param_select_opts
    @filter_param_select_opts = []

    @@filter_params_map.each {  |key, value|
      @filter_param_select_opts << [value, key.to_s]
    }

    @filter_param_select_opts.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @filter_param_select_opts.reverse!

    @filter_param_select_opts
  end

  def is_public
    symbol != nil
  end

  def user_subscription_amount user
    @sum = 0

    project_subscriptions.find_all_by_user_id(user.id).each do |sub|
      @sum += sub.amount
    end

    @sum
  end

  def user_subscription_amount_outstanding user
    @sum = 0

    project_subscriptions.find_all_by_user_id_and_outstanding(user.id, true).each do |sub|
      @sum += sub.amount
    end

    @sum
  end

  def subscription_amount
    ProjectSubscription.calculate_amount project_subscriptions
  end

  def symbol
    if !super
      return nil
    end
    
    super.upcase
  end

  def share_queue
    @share_queue ||= ProjectSubscription.share_queue self
  end

  #get the end of the queue that has not been assigned a payment yet
  def share_queue_pending
    @share_queue_pending ||= ProjectSubscription.share_queue_pending self
  end

  def share_queue_pending_pmf_fund
    @share_queue_pending_pmf_fund ||= ProjectSubscription.share_queue_pending_pmf_fund self
  end

  def ordered_subscribers
    share_queue.collect(&:user).uniq
  end

  def ordered_subscribers_for_basic_membership
    ordered_subscribers_for_membership_type(MembershipType.find_by_name("Basic"))
  end
  
  def ordered_subscribers_for_gold_membership
    ordered_subscribers_for_membership_type(MembershipType.find_by_name("Gold"))
  end

  def ordered_subscribers_for_platinum_membership
    ordered_subscribers_for_membership_type(MembershipType.find_by_name("Platinum"))
  end

  def ordered_subscribers_for_black_pearl_membership
    ordered_subscribers_for_membership_type(MembershipType.find_by_name("Black Pearl"))
  end

  def ordered_subscribers_for_membership_type membership_type
    @subs = share_queue.reject do |ps|
      ps.user.membership.membership_type_id != membership_type.id
    end

    @subs.collect(&:user).uniq.collect(&:profile)
  end

  def in_payment_phases?
    in_payment? || finished_payment_collection
  end

  def in_payment?
    project_payment_status == "In Payment"
  end

  def finished_payment_collection
    project_payment_status == "Finished Payment"
  end

  def current_payment_window
    payment_windows.find(:first, :conditions => "status = 'Active'", :order => "created_at DESC")
  end

  def amount_payment_collected
    @amount = 0

    subscription_payments.each do |sp|
      if sp.paid?
        @amount += (sp.share_amount * sp.share_price)
      end
    end

    @amount
  end

  #how mush is still to be collected in the payment stage
  def amount_payment_outstanding
    capital_required - amount_payment_collected
  end

  #how many shares are to be collected in the payment stage
  def amount_shares_outstanding_payment
    @amount_shares_paid_for = 0

    subscription_payments.each do |sp|
      if sp.paid?
        @amount_shares_paid_for += sp.share_amount
      end
    end

    (total_copies - @amount_shares_paid_for).to_i
  end
  
  def bitpay_grace_period?
    if in_payment? and true#!bitpay_email.blank?
      @pw = current_payment_window
      
      @now = Time.now
      
      #for testing
      #@now = Time.parse("Tue May 25 00:45:53 +0100 2012")
      
      #close the window 1 hour before 1am on the window close date to allow bitpay grace period
      @after_grace_period_start = (1.day.from_now(@pw.close_date.midnight) < @now)
      @before_window_close = (25.hours.from_now(@pw.close_date.midnight) > @now)
      
      if(@after_grace_period_start and @before_window_close)
        return true
      else 
        return false
      end
    else
      return false
    end
  end
  
  def frozen_yellow?
    #we have to add !finished_payment_collection to deal with old projects that were funded through paypal
    bitpay_email.blank? and yellow_light and !finished_payment_collection
  end

  def mark_as_finished_payment
    self.project_payment_status = "Finished Payment"
    self.fully_funded_time = Time.now
    self.save_without_validating
  end

  def share_queue_exhausted?
    project_subscriptions.find(:all, :conditions => "subscription_payment_id is null").empty?
  end

  def amount_shares_left_in_share_queue
    @subs = project_subscriptions.find(:all, :conditions => "subscription_payment_id is null")

    @amount = 0

    @subs.each do |sub|
      @amount += sub.amount
    end

    @amount
  end

  def pmf_share_buyout_open?
    if pmf_share_buyout
      return pmf_share_buyout.open?
    end

    return false
  end

  def pmf_share_buyout_accepted?
    if pmf_share_buyout
      return pmf_share_buyout.accepted?
    end

    return false
  end

  def pmf_share_buyout_denied?
    if pmf_share_buyout
      return pmf_share_buyout.denied?
    end

    return false
  end

  def pmf_share_buyout_pending?
    if pmf_share_buyout
      return pmf_share_buyout.pending?
    end

    return false
  end

  def pmf_share_buyout_verified?
    if pmf_share_buyout
      return pmf_share_buyout.verified?
    end

    return false
  end

  def pmf_share_buyout_paypal_id
    "buyout_request_##{pmf_share_buyout.id}"
  end

  def last_window_paypal_email
    payment_windows.find(:first, :order => "created_at DESC").paypal_email
  end

  def is_flagged
    project_flaggings.size > 0
  end

  def unflag
    ProjectFlagging.destroy project_flaggings.collect(&:id)
  end

  def self.all_flagged
    find(:all, :include => :project_flaggings, :group => "projects.id",
      :conditions => "project_flaggings.id is not null and projects.is_deleted = 0",
      :order => "count(project_flaggings.id) DESC")
  end

  def self.all_funded
    find(:all, :conditions => "project_payment_status = 'Finished Payment'")
  end

  def self.all_funded_amount
    sum(:capital_required, :conditions => "project_payment_status = 'Finished Payment'")
  end

  def gensym
    generate_symbol
  end

  def user_login
    owner.profile.user_login
  end

  def user_full_name
    owner.f
  end
  
  def num_all_payment_users
    @all_payment_user_ids = subscription_payments.collect(&:user_id).uniq
    @all_payment_user_ids.size
  end
  
  def num_completed_payment_users
    @completed_payment_user_ids = completed_payments.collect(&:user_id).uniq
    @completed_payment_user_ids.size
  end
  
  def num_defaulted_payment_users
    @defaulted_payment_user_ids = defaulted_payments.collect(&:user_id).uniq
    @defaulted_payment_user_ids.size
  end

  protected

  def generate_symbol
    gen_symbol = title.downcase
    gen_symbol = gen_symbol.gsub("and", "").gsub("the", "").gsub(" ", "").gsub(/\W/, "")
    gen_symbol = gen_symbol[0..4]

    while Project.find_by_symbol gen_symbol
      chars = ('a'..'z').to_a | ('0'..'9').to_a
      gen_symbol[4] = chars[rand(36)]
    end

    self.write_attribute("symbol", gen_symbol)
    
    save
  end

  def validate
    validate_yellow_light_fields
    validate_green_light_fields
    errors.add(:share_percent_ads_producer, "must be between 0% - 100%") if share_percent_ads_producer && (share_percent_ads_producer < 0 || share_percent_ads_producer > 100)
    errors.add(:share_percent_ads, "must be 0% if producer % is 0") if share_percent_ads_producer && share_percent_ads_producer == 0 && share_percent_ads > 0
    errors.add(:share_percent_ads, "must be between 0% - 100%") if share_percent_ads && (share_percent_ads < 0 || share_percent_ads > 100)
    errors.add(:producer_fee_percent, "must be between 0% - 100%") if producer_fee_percent && (producer_fee_percent < 0 || producer_fee_percent > 100)
    errors.add(:capital_required, "must be a multiple of your share price") if capital_required % ipo_price !=0 || capital_required < ipo_price
    errors.add(:symbol, "must be 5 characters long") if symbol && !symbol.blank? && !(symbol=~/[0-9a-zA-Z]{5}/)
    #    errors.add(:bitpay_email, "Can only choose either bitpay or paypal") if !bitpay_email.blank? and !paypal_email.blank?
    #    errors.add(:paypal_email, "Can only choose either bitpay or paypal") if !bitpay_email.blank? and !paypal_email.blank?
    logger.info "Validation Errors: #{errors_to_s}"
  end
  
  def validate_yellow_light_fields
    if yellow_light
      #must not perform the change? check if the old val of the attribute was 0 due to some bug????

      errors.add(:capital_required, "cannot be modified in yellow light stage, proper value was #{capital_required_was}") if capital_required_was != 0 && capital_required_changed?
      errors.add(:share_percent_ads_producer, "cannot be modified in yellow light stage, proper value was #{share_percent_ads_producer_was}") if share_percent_ads_producer_was !=0 && share_percent_ads_producer_changed?
      errors.add(:share_percent_ads, "cannot be modified in yellow light stage, proper value was #{share_percent_ads_was}") if share_percent_ads_was !=0 && share_percent_ads_changed?
      errors.add(:producer_fee_percent, "cannot be modified in yellow light stage, proper value was #{producer_fee_percent_was}") if producer_fee_percent_was != 0 && producer_fee_percent_changed?
    end
  end

  def validate_green_light_fields
    if green_light
      #must not perform the change? check if the old val of the attribute was 0 due to some bug????

      errors.add(:capital_required, "cannot be modified in green light stage, proper value was #{capital_required_was}") if capital_required_was != 0 && capital_required_changed?
      errors.add(:share_percent_ads_producer, "cannot be modified in green light stage, proper value was #{share_percent_ads_producer_was}") if share_percent_ads_producer_was !=0 && share_percent_ads_producer_changed?
      errors.add(:share_percent_ads, "cannot be modified in green light stage, proper value was #{share_percent_ads_was}") if share_percent_ads_was !=0 && share_percent_ads_changed?
      errors.add(:producer_fee_percent, "cannot be modified in green light stage, proper value was #{producer_fee_percent_was}") if producer_fee_percent_was != 0 && producer_fee_percent_changed?
      
      #errors.add(:paypal_email, "cannot be modified in green light stage, proper value was #{paypal_email_was}") if paypal_email_changed?
      errors.add(:bitpay_email, "cannot be modified in green light stage, proper value was #{bitpay_email_was}") if bitpay_email_changed?
    end
  end

  def funding_limit_not_exceeded
    #set funding limit equal to either the users limit, or the current demand
    #TODO: have to record each time the budget has been pushed 
    
    
    
    funding_limit = owner.membership_type.funding_limit_per_project
    
    if !self.is_deleted && !self.in_payment? && !green_light && self.capital_required > funding_limit
      errors.add(:capital_required, " must be less than $#{funding_limit}, the limit for your membership type.")
    end
  end

  def min_funding_limit_passed
    min_funding_limit = owner.membership_type.min_funding_limit_per_project

    if !self.is_deleted && !self.in_payment? && !green_light && self.capital_required < min_funding_limit
      errors.add(:capital_required, " must be greater than or equal to $#{min_funding_limit}, the limit for your membership type.")
    end
  end

  def update_recycled_percent
    self.capital_recycled_percent = 100 - share_percent_ads_producer
  end

end








# == Schema Information
#
# Table name: projects
#
#  id                               :integer(4)      not null, primary key
#  owner_id                         :integer(4)
#  title                            :string(255)
#  producer_name                    :string(255)
#  synopsis                         :text
#  genre_id                         :integer(4)
#  description                      :text
#  cast                             :text
#  web_address                      :string(255)
#  ipo_price                        :decimal(10, 2)
#  percent_funded                   :integer(3)
#  icon                             :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  youtube_vid_id                   :string(255)
#  status                           :string(255)     default("Funding")
#  project_length                   :integer(4)      default(0)
#  share_percent_downloads          :integer(3)
#  share_percent_ads                :integer(3)
#  downloads_reserved               :integer(10)     default(0)
#  downloads_available              :integer(10)     default(0)
#  capital_required                 :integer(12)
#  rated_at                         :datetime
#  is_deleted                       :boolean(1)      default(FALSE)
#  deleted_at                       :datetime
#  member_rating                    :integer(4)      default(0)
#  admin_rating                     :integer(4)      default(0)
#  director                         :string(255)
#  writer                           :string(255)
#  exec_producer                    :string(255)
#  producer_fee_percent             :integer(4)
#  capital_recycled_percent         :integer(4)
#  share_percent_ads_producer       :integer(4)      default(0)
#  producer_dividend                :float           default(0.0)
#  shareholder_dividend             :float           default(0.0)
#  symbol                           :string(255)
#  fund_dividend                    :float           default(0.0)
#  pmf_fund_investment_percentage   :integer(4)      default(0)
#  green_light                      :datetime
#  director_photography             :string(255)
#  editor                           :string(255)
#  pmf_fund_investment_share_amount :integer(4)      default(0)
#  project_payment_status           :string(255)
#  fully_funded_time                :datetime
#  watch_url                        :string(255)
#  percent_bad_shares               :integer(4)      default(0)
#  main_video                       :string(255)
#  daily_percent_move               :integer(4)      default(0)
#  paypal_email                     :string(255)
#  yellow_light                     :datetime
#  actors                           :string(255)
#  bitpay_email                     :string(255)
#  weeks_to_finish                  :integer(4)
#

