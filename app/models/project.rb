class Project < ActiveRecord::Base    

  @@PROJECT_STATUSES = ["Funding", "In Production", "Release"]

  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many   :project_subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :project_subscriptions, :source=> :user
  
  belongs_to :genre, :foreign_key=>'genre_id'
  
  validates_presence_of :owner_id, :title, :status
  validates_presence_of :capital_required, :ipo_price

  validates_inclusion_of :status, :in => @@PROJECT_STATUSES

  validates_uniqueness_of :title
  
  validates_numericality_of :capital_required, :ipo_price, :project_length
  validates_numericality_of :share_percent_downloads, :share_percent_ads, :allow_nil => true
  
  acts_as_ferret :fields => [ :title, :synopsis, :description ], :remote=>true

  has_one :project_rating

  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }
  
  def self.search query = '', options = {}
    logger.debug "Searching for projects with query #{query}"
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = find_by_contents q, :limit=>:all
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

  protected
  
  def validate
    errors.add(:share_percent_downloads, "Must be a percentage (0 - 100)") if share_percent_downloads && (share_percent_downloads < 0 || share_percent_downloads > 100)
    errors.add(:share_percent_ads, "Must be a percentage (0 - 100)") if share_percent_ads && (share_percent_ads < 0 || share_percent_ads > 100)
    errors.add(:capital_required, "Capital Required must be a multiple of your download unit price") if capital_required % ipo_price !=0 || capital_required < ipo_price
  end
  
end
