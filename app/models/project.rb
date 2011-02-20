# == Schema Information
# Schema version: 20110110160522
#
# Table name: projects
#
#  id                               :integer(4)    not null, primary key
#  owner_id                         :integer(4)    
#  title                            :string(255)   
#  producer_name                    :string(255)   
#  synopsis                         :text          
#  genre_id                         :integer(4)    
#  description                      :text          
#  cast                             :text          
#  web_address                      :string(255)   
#  ipo_price                        :decimal(10, 2 
#  percent_funded                   :integer(3)    
#  icon                             :string(255)   
#  created_at                       :datetime      
#  updated_at                       :datetime      
#  youtube_vid_id                   :string(255)   
#  status                           :string(255)   default("Funding")
#  project_length                   :integer(4)    default(0)
#  share_percent_downloads          :integer(3)    
#  share_percent_ads                :integer(3)    
#  downloads_reserved               :integer(10)   default(0)
#  downloads_available              :integer(10)   default(0)
#  capital_required                 :integer(12)   
#  rated_at                         :datetime      
#  is_deleted                       :boolean(1)    
#  deleted_at                       :datetime      
#  member_rating                    :integer(4)    default(0)
#  admin_rating                     :integer(4)    default(0)
#  director                         :string(255)   
#  writer                           :string(255)   
#  exec_producer                    :string(255)   
#  producer_fee_percent             :integer(4)    
#  capital_recycled_percent         :integer(4)    
#  share_percent_ads_producer       :integer(4)    default(0)
#  producer_dividend                :float         default(0.0)
#  shareholder_dividend             :float         default(0.0)
#  symbol                           :string(255)   
#  fund_dividend                    :float         default(0.0)
#  pmf_fund_investment_percentage   :integer(4)    
#  green_light                      :datetime      
#  director_photography             :string(255)   
#  editor                           :string(255)   
#  pmf_fund_investment_share_amount :integer(4)    default(0)
#  project_payment_status           :string(255)   
#  producer_talent_id               :integer(4)    
#  director_talent_id               :integer(4)    
#  writer_talent_id                 :integer(4)    
#  exec_producer_talent_id          :integer(4)    
#  director_photography_talent_id   :integer(4)    
#  editor_talent_id                 :integer(4)    
#

class Project < ActiveRecord::Base    

  @@PROJECT_STATUSES = ["Pre Production", "In Production", "Post Production",
    "Finishing Funds", "Trailer", "In Release"]

  @@PROJECT_PAYMENT_STATUSES = ["In Payment", "Finished Payment"]
  
  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many :project_subscriptions, :dependent => :destroy
  has_many :subscribers, :through => :project_subscriptions, :source => :user,
    :order => "project_subscriptions.created_at", :group => "id"

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
  validates_length_of :description, :within => 0..140
  validates_length_of :title, :minimum => 5
  
  validates_numericality_of :capital_required, :ipo_price, :project_length, :allow_nil => true
  validates_numericality_of :capital_recycled_percent, :producer_fee_percent, :allow_nil => true
  validates_numericality_of :share_percent_ads, :allow_nil => true

  validates_filesize_of :icon, {:in => 0.kilobytes..1.megabyte, :message => "Your Project Image must be less than 1 megabyte"}

  validate_on_create :funding_limit_not_exceeded, :min_funding_limit_passed
  validate_on_update :funding_limit_not_exceeded, :min_funding_limit_passed

  acts_as_ferret :fields => [ :title, :synopsis, :description, 
    :user_login, :user_full_name, :director, :writer, :exec_producer,
    :director_photography, :editor ], :remote => true

  #note that we duplicate the following data as we need it to sort and order projects on the browse page
  #this makes the queries run faster
  has_one :project_rating, :dependent => :destroy
  
  has_one :admin_project_rating, :order => "created_at DESC", :dependent => :destroy
  has_many :admin_project_ratings, :order => "created_at DESC", :dependent => :destroy
  has_many :pmf_fund_subscription_histories, :dependent => :destroy

  has_many :subscription_payments
  has_many :payment_windows

  has_one :pmf_share_buyout
  
  has_many :project_comments, :dependent => :destroy
  has_one :latest_project_comment, :class_name => "ProjectComment", :order => "created_at DESC"

  belongs_to :director_talent, :class_name => "UserTalent", :foreign_key => 'director_talent_id'
  belongs_to :writer_talent, :class_name => "UserTalent", :foreign_key => 'writer_talent_id'
  belongs_to :exec_producer_talent, :class_name => "UserTalent", :foreign_key => 'exec_producer_talent_id'
  belongs_to :director_photography_talent, :class_name => "UserTalent", :foreign_key => 'director_photography_talent_id'
  belongs_to :editor_talent, :class_name => "UserTalent", :foreign_key => 'editor_talent_id'
  belongs_to :producer_talent, :class_name => "UserTalent", :foreign_key => 'producer_talent_id'

  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  after_create :generate_symbol
  before_save :set_talent

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

    
    options = args[0]

    if options[:conditions]
      options[:conditions] << sanitize_sql(' AND symbol IS NOT NULL')
    else
      options[:conditions] = sanitize_sql('symbol IS NOT NULL')
    end

    options[:conditions] << sanitize_sql(' AND is_deleted = 0 ')

    @projects = self.find(:all, options)

    @projects
    
  end

  def self.find_single_public(id)

    @project = self.find(id)
    
    if @project.symbol && !@project.is_deleted
      return @project
    else
      return nil
    end
  end

  def self.find_all_for_talent_id talent_id
    Project.find(:all, :conditions => "director_talent_id = #{talent_id} or
      writer_talent_id = #{talent_id} or exec_producer_talent_id = #{talent_id}
      or director_photography_talent_id = #{talent_id} or editor_talent_id = #{talent_id}
      or producer_talent_id = #{talent_id}")
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
    @downloads_reserved = project_subscriptions.collect { |s| s.amount }.sum - self.pmf_fund_investment_share_amount_incl_outstanding
    self.downloads_reserved = @downloads_reserved
    self.downloads_available = @total_copies - self.downloads_reserved
    self.percent_funded = (downloads_reserved * 100) / @total_copies
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

    @pmf_fund_user = User.find(PMF_FUND_ACCOUNT_ID)

    @subscriptions = ProjectSubscription.load_non_outstanding_subscriptions @pmf_fund_user, self
    @subscription_amount = ProjectSubscription.calculate_amount @subscriptions

    if @subscription_amount >= 0
      self.pmf_fund_investment_share_amount = @subscription_amount
      self.pmf_fund_investment_percentage = (@subscription_amount/total_copies) * 100
    end
  end

  def pmf_fund_investment_share_amount_incl_outstanding
    @pmf_fund_user = User.find(PMF_FUND_ACCOUNT_ID)

    @subscriptions = ProjectSubscription.load_subscriptions @pmf_fund_user, self
    @subscription_amount = ProjectSubscription.calculate_amount @subscriptions
  end

  def pmf_fund_investment_total
    self.pmf_fund_investment_share_amount * self.ipo_price
  end

  def percent_funded_with_pmf_fund_non_outstanding
    percent_funded + pmf_fund_investment_percentage
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
    1 => "Please Choose...", 2 => "% Funded All", 3 => "% Funded - Pre Production",
    4 => "% Funded - In Production", 5 => "% Funded - Post Production", 6 => "% Funded - Finishing Funds",
    7 => "% Funded - Trailer", 8 => "Funds Needed", 9 => "Funds Reserved",
    10 => "PMF Fund Rating", 11 => "Member Rating", 12 => "Newest", 13 => "Oldest",
    #14 => "Producer Dividend", 15 => "Shareholder Dividend", 16 => "PMF Fund Dividend",
    #17 => "% PMF Fund Shares",
    #18 => "No. PMF Fund Shares",
    19 => "Green Light", 20 => "Fully Funded", 21 => "In Payment"
  }

  def self.get_filter_sql filter_param

    @payment_status_filter = "(project_payment_status is null or project_payment_status != 'Finished Payment')"

    case filter_param
    when "2" then return @payment_status_filter
    when "3" then return "status = \"Pre Production\" and #{@payment_status_filter}"
    when "4" then return "status = \"In Production\" and #{@payment_status_filter}"
    when "5" then return "status = \"Post Production\" and #{@payment_status_filter}"
    when "6" then return "status = \"Finishing Funds\" and #{@payment_status_filter}"
    when "7" then return "genre_id = #{Genre.find_by_title("Trailer").id} and #{@payment_status_filter}"
    when "8" then return @payment_status_filter
    when "9" then return @payment_status_filter
    when "10" then return @payment_status_filter
    when "11" then return @payment_status_filter
    when "12" then return @payment_status_filter
    when "13" then return @payment_status_filter
    when "14" then return @payment_status_filter
    when "15" then return @payment_status_filter
    when "16" then return @payment_status_filter
    when "17" then return @payment_status_filter
    when "18" then return @payment_status_filter
    when "19" then return "#{@payment_status_filter} and green_light is NOT NULL"
    when "20" then return "project_payment_status = 'Finished Payment'"
    when "21" then return "project_payment_status = 'In Payment'"
    else return @payment_status_filter
    end
  end

  def self.get_order_sql filter_param
    case filter_param
    when "2" then return "percent_funded DESC"
    when "3" then return "percent_funded DESC"
    when "4" then return "percent_funded DESC"
    when "5" then return "percent_funded DESC"
    when "6" then return "percent_funded DESC"
    when "7" then return "percent_funded DESC"
    when "8" then return "capital_required DESC"
    when "9" then return "(downloads_reserved * ipo_price) DESC"
    when "10" then return "admin_rating DESC"
    when "11" then return "member_rating DESC"
    when "12" then return "created_at DESC"
    when "13" then return "created_at ASC"
      #    when "14" then return "producer_dividend DESC"
      #    when "15" then return "shareholder_dividend DESC"
      #    when "16" then return "fund_dividend DESC"
      #    when "17" then return "pmf_fund_investment_percentage DESC"
    when "18" then return "pmf_fund_investment_share_amount DESC"
    when "19" then return "green_light DESC"
    when "20" then return "fully_funded_time DESC"
    when "21" then return "green_light DESC"
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

    project_subscriptions.find_all_by_user_id_and_outstanding(user.id, false).each do |sub|
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
    ProjectSubscription.share_queue self
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

  def mark_as_finished_payment
    self.project_payment_status = "Finished Payment"
    self.fully_funded_time = Time.now
    self.save_without_validating
  end

  def share_queue_exhausted?
    project_subscriptions.find(:all, :conditions => "subscription_payment_id is null").empty?
  end

  def share_queue_has_enough_funds_left
    amount_shares_left_in_share_queue >= amount_shares_outstanding_payment
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

  protected

  def generate_symbol
    gen_symbol = title.downcase
    gen_symbol = gen_symbol.gsub("and", "").gsub("the", "Ruby").gsub(" ", "")
    gen_symbol = gen_symbol[0..4]

    while Project.find_by_symbol gen_symbol
      chars = ('a'..'z').to_a | ('0'..'9').to_a
      gen_symbol[4] = chars[rand(36)]
    end

    self.write_attribute("symbol", gen_symbol)
    
    save
  end

  def validate
    validate_green_light_fields
    errors.add(:share_percent_ads_producer, "must be between 0% - 100%") if share_percent_ads_producer && (share_percent_ads_producer < 0 || share_percent_ads_producer > 100)
    errors.add(:share_percent_ads, "must be 0% if producer % is 0") if share_percent_ads_producer && share_percent_ads_producer == 0 && share_percent_ads > 0
    errors.add(:share_percent_ads, "must be between 0% - 100%") if share_percent_ads && (share_percent_ads < 0 || share_percent_ads > 100)
    errors.add(:producer_fee_percent, "must be between 0% - 100%") if producer_fee_percent && (producer_fee_percent < 0 || producer_fee_percent > 100)
    errors.add(:capital_required, "must be a multiple of your share price") if capital_required % ipo_price !=0 || capital_required < ipo_price
    errors.add(:symbol, "must be 5 characters long") if symbol && !symbol.blank? && !(symbol=~/[0-9a-zA-Z]{5}/)
    logger.info "Validation Errors: #{errors_to_s}"
  end

  def validate_green_light_fields
    if green_light
      #must not perform the change? check if the old val of the attribute was 0 due to some bug????

      errors.add(:capital_required, "cannot be modified in green light stage, proper value was #{capital_required_was}") if capital_required_was != 0 && capital_required_changed?
      errors.add(:share_percent_ads_producer, "cannot be modified in green light stage, proper value was #{share_percent_ads_producer_was}") if share_percent_ads_producer_was !=0 && share_percent_ads_producer_changed?
      errors.add(:share_percent_ads, "cannot be modified in green light stage, proper value was #{share_percent_ads_was}") if share_percent_ads_was !=0 && share_percent_ads_changed?
      errors.add(:producer_fee_percent, "cannot be modified in green light stage, proper value was #{producer_fee_percent_was}") if producer_fee_percent_was != 0 && producer_fee_percent_changed?
    end
  end

  def funding_limit_not_exceeded
    #set funding limit equal to either the users limit, or the current demand
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

  def set_talent
    #check if any of the talent ids are set, and set the text fields accordingly
    if director_talent_id
      self.director = director_talent.user.login
    end

    if writer_talent_id
      self.writer = writer_talent.user.login
    end

    if exec_producer_talent_id
      self.exec_producer = exec_producer_talent.user.login
    end

    if director_photography_talent_id
      self.director_photography = director_photography_talent.user.login
    end

    if editor_talent_id
      self.editor = editor_talent.user.login
    end

    if producer_talent_id
      self.producer_name = producer_talent.user.login
    end
  end

end
