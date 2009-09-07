# == Schema Information
# Schema version: 20090526045351
#
# Table name: projects
#
#  id                      :integer(4)    not null, primary key
#  owner_id                :integer(4)    
#  title                   :string(255)   
#  producer_name           :string(255)   
#  synopsis                :text          
#  genre_id                :integer(4)    
#  description             :text          
#  cast                    :text          
#  web_address             :string(255)   
#  ipo_price               :decimal(10, 2 
#  percent_funded          :integer(3)    
#  icon                    :string(255)   
#  created_at              :datetime      
#  updated_at              :datetime      
#  youtube_vid_id          :string(255)   
#  status                  :string(255)   default("Funding")
#  project_length          :integer(4)    default(0)
#  share_percent_downloads :integer(3)    
#  share_percent_ads       :integer(3)    
#  downloads_reserved      :integer(10)   default(0)
#  downloads_available     :integer(10)   default(0)
#  capital_required        :integer(12)   
#

class Project < ActiveRecord::Base    

  @@PROJECT_STATUSES = ["Funding", "In Production", "Release"]
  
  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many   :project_subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :project_subscriptions, :source=> :user
  
  belongs_to :genre, :foreign_key=>'genre_id'
  
  validates_presence_of :owner_id, :title, :status, :genre_id
  validates_presence_of :capital_required, :ipo_price

  validates_inclusion_of :status, :in => @@PROJECT_STATUSES

  validates_uniqueness_of :title
  
  validates_numericality_of :capital_required, :ipo_price, :project_length
  validates_numericality_of :share_percent_downloads, :share_percent_ads, :allow_nil => true

  validates_filesize_of :icon, {:in => 0.kilobytes..1.megabyte, :message => "Your Project Image must be less than 1 megabyte"}

  validate_on_create :funding_limit_not_exceeded
  
  acts_as_ferret :fields => [ :title, :synopsis, :description ], :remote=>true

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
    arr = find_by_contents q, {:limit=>:all}, {:conditions => 'rated_at IS NOT NULL'}
    logger.debug arr.inspect
    arr
  end   

  def self.statuses
    @@PROJECT_STATUSES
  end

  def update_funding
    logger.debug "Updating percent funded"
    @total_copies = total_copies
    self.downloads_reserved = project_subscriptions.collect { |s| s.amount }.sum 
    self.downloads_available = @total_copies - self.downloads_reserved
    self.percent_funded = (self.downloads_reserved * 100) / @total_copies
    self.save!
  end

  def total_copies
    capital_required / ipo_price
  end

  def share_percent_downloads
    if !super
      self.share_percent_downloads = 0
      self.save!
    end

    super
  end

  def share_percent_ads
    if !super
      self.share_percent_ads = 0
      self.save!
    end

    super
  end

  def self.filter_params
    ["Order Projects By...", "% funds reserved", "member rating", "admin rating", "newest", "oldest"]
  end

  protected
  
  def validate
    errors.add(:share_percent_downloads, "Must be a percentage (0 - 100)") if share_percent_downloads && (share_percent_downloads < 0 || share_percent_downloads > 100)
    errors.add(:share_percent_ads, "Must be a percentage (0 - 100)") if share_percent_ads && (share_percent_ads < 0 || share_percent_ads > 100)
    errors.add(:capital_required, "Capital Required must be a multiple of your download unit price") if capital_required % ipo_price !=0 || capital_required < ipo_price
  end

  def funding_limit_not_exceeded
    funding_limit = owner.membership_type.funding_limit_per_project
    
    if self.capital_required > funding_limit && funding_limit != -1
      errors.add(:capital_required, "Capital Required must be less than $#{funding_limit}, the limit for your membership type,
          We will be allowing account upgrades shortly!")
    end
  end
end
