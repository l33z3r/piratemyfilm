# == Schema Information
# Schema version: 20100528091908
#
# Table name: projects
#
#  id                       :integer(4)    not null, primary key
#  owner_id                 :integer(4)    
#  title                    :string(255)   
#  producer_name            :string(255)   
#  synopsis                 :text          
#  genre_id                 :integer(4)    
#  description              :text          
#  cast                     :text          
#  web_address              :string(255)   
#  ipo_price                :decimal(10, 2 
#  percent_funded           :integer(3)    
#  icon                     :string(255)   
#  created_at               :datetime      
#  updated_at               :datetime      
#  youtube_vid_id           :string(255)   
#  status                   :string(255)   default("Funding")
#  project_length           :integer(4)    default(0)
#  share_percent_downloads  :integer(3)    
#  share_percent_ads        :integer(3)    
#  downloads_reserved       :integer(10)   default(0)
#  downloads_available      :integer(10)   default(0)
#  capital_required         :integer(12)   
#  rated_at                 :datetime      
#  is_deleted               :boolean(1)    
#  deleted_at               :datetime      
#  member_rating            :integer(4)    default(0)
#  admin_rating             :integer(4)    default(0)
#  director                 :string(255)   
#  writer                   :string(255)   
#  exec_producer            :string(255)   
#  breakeven_views          :float         
#  producer_fee_percent     :integer(4)    
#  capital_recycled_percent :integer(4)    
#

class Project < ActiveRecord::Base    

  @@PROJECT_STATUSES = ["Funding", "In Production", "Release"]
  
  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many   :project_subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :project_subscriptions, :source=> :user

  has_many :blogs
  
  belongs_to :genre, :foreign_key=>'genre_id'
  
  validates_presence_of :owner_id, :title, :status
  validates_presence_of :ipo_price, :genre_id, :capital_required
  
  validates_inclusion_of :status, :in => @@PROJECT_STATUSES

  validates_uniqueness_of :title

  #description will be the logline of the project
  #we are limiting it to 140 characters so that it is like twitter
  validates_length_of :description, :within => 0..140

  validates_numericality_of :capital_required, :ipo_price, :project_length, :allow_nil => true
  validates_numericality_of :capital_recycled_percent, :producer_fee_percent, :allow_nil => true
  validates_numericality_of :share_percent_ads, :allow_nil => true

  validates_filesize_of :icon, {:in => 0.kilobytes..1.megabyte, :message => "Your Project Image must be less than 1 megabyte"}

  validate_on_create :funding_limit_not_exceeded, :min_funding_limit_passed
  validate_on_update :funding_limit_not_exceeded, :min_funding_limit_passed

  acts_as_ferret :fields => [ :title, :synopsis, :description ], :remote => true

  #note that we duplicate the following data as we need it to sort and order projects on the browse page
  #this makes the queries run faster
  has_one :project_rating

  has_one :admin_project_rating
  has_one :project_comment

  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  #find projects that have been given initial rating and are not deleted
  def self.find_all_public(*args)

    #TODO: use with_scope

    
    options = args[0]

    if options[:conditions]
      options[:conditions] << sanitize_sql(' AND rated_at IS NOT NULL')
    else
      options[:conditions] = sanitize_sql('rated_at IS NOT NULL')
    end

    options[:conditions] << sanitize_sql(' AND is_deleted = 0')

    @projects = self.find(:all, options)

    @projects
    
  end

  def self.find_single_public(id)

    @project = self.find(id)
    
    if @project.rated_at && !@project.is_deleted
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
    arr = find_by_contents q, {:limit=>:all}, {:conditions => 'rated_at IS NOT NULL and is_deleted = 0'}
    logger.debug arr.inspect
    arr
  end   

  def self.statuses
    @@PROJECT_STATUSES
  end

  #overide save to perform updating of estimates
  def save!
    logger.debug "overriden save called!"
    update_funding
    update_estimates
    super
  end

  #this is simply here for completeness...
  def update_funding_and_estimates
    self.save!
  end

  def update_funding
    logger.debug "Updating percent funded"
    @total_copies = total_copies
    self.downloads_reserved = project_subscriptions.collect { |s| s.amount }.sum
    self.downloads_available = @total_copies - self.downloads_reserved
    self.percent_funded = (self.downloads_reserved * 100) / @total_copies
  end

  def update_estimates
    logger.debug "Updating Estimates!"

    if self.share_percent_ads > 0
      @ad_sales_required = (100 * self.capital_required)/self.share_percent_ads
      @cpm_presumption = 10
      self.breakeven_views = (@ad_sales_required/@cpm_presumption) * 1000
    end
  end

  def user_rating
    @user_project_rating = ProjectRating.find_by_project_id id
    @user_project_rating ? @user_project_rating.rating_symbol : ProjectRating.ratings_map[1]
  end

  def admin_rating
    admin_project_rating ? admin_project_rating.rating_symbol : AdminProjectRating.ratings_map[1]
  end

  def admin_comment
    ProjectComment.find_by_project_id id
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

  def delete
    self.is_deleted = true
    self.deleted_at = Time.now
    self.save!
  end

  def restore
    self.is_deleted = false
    self.deleted_at = nil
    self.save!
  end

  def self.filter_params
    ["Please Choose...", "% funds reserved", "breakeven", "member rating", "admin rating", "newest", "oldest"]
  end

  protected
  
  def validate
    errors.add(:share_percent_ads, "must be between 0% - 100%") if share_percent_ads && (share_percent_ads < 0 || share_percent_ads > 100)
    errors.add(:producer_fee_percent, "must be between 0% - 20%") if producer_fee_percent && (producer_fee_percent < 0 || producer_fee_percent > 20)
    errors.add(:capital_recycled_percent, "must be between 0% - 100%") if capital_recycled_percent && (capital_recycled_percent < 0 || capital_recycled_percent > 100)

    errors.add(:capital_required, "must be a multiple of your share price") if capital_required % ipo_price !=0 || capital_required < ipo_price

    #must check that total percentage adds up correctly
    if share_percent_ads + capital_recycled_percent > 100
      @exceeded_error_message = "% Ad Sales and % Capital Recycled to PMF must sum to less than 100%"
      errors.add(:share_percent_ads, @exceeded_error_message)
      errors.add(:capital_recycled_percent, @exceeded_error_message)
    end

  end

  def funding_limit_not_exceeded
    funding_limit = owner.membership_type.funding_limit_per_project
    
    if self.capital_required > funding_limit && funding_limit != -1
      errors.add(:capital_required, " must be less than $#{funding_limit}, the limit for your membership type,
          We will be allowing account upgrades shortly!")
    end
  end

  def min_funding_limit_passed
    min_funding_limit = owner.membership_type.min_funding_limit_per_project

    if self.capital_required < min_funding_limit
      errors.add(:capital_required, " must be greater than $#{min_funding_limit}, the limit for your membership type,
          We will be allowing account upgrades shortly!")
    end
  end

end
