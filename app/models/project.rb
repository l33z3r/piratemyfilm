class Project < ActiveRecord::Base    

  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many   :project_subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :project_subscriptions, :source=> :user
  
  belongs_to :genre, :foreign_key=>'genre_id'
  
  validates_presence_of :owner_id, :title, :producer_name, :synopsis
  validates_presence_of :description, :capital_required, :ipo_price, :share_percent
  
  validates_uniqueness_of :title
  
  validates_numericality_of :capital_required, :ipo_price, :share_percent
  
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
  
  def update_funding
    logger.debug "Updating percent funded"
    self.downloads_reserved = (project_subscriptions.collect { |s| s.amount }.sum ) * ipo_price
    self.downloads_available = capital_required - downloads_reserved
    self.percent_funded = (downloads_reserved * 100) / capital_required
    self.save!
  end
  
  protected
  
  def validate
    errors.add(:share_percent, "Must be a percentage (0 - 100)") if share_percent.nil? || share_percent < 0 || share_percent > 100
  end
  
end
