class Project < ActiveRecord::Base    

  belongs_to :owner, :class_name=>'User', :foreign_key=>'owner_id'
  
  has_many   :project_subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :project_subscriptions, :source=> :user
  
  belongs_to :genre, :foreign_key=>'genre_id'
  
  validates_presence_of :owner_id, :title, :producer_name, :synopsis
  validates_presence_of :description, :capital_required, :ipo_price, :share_percent
  
  validates_uniqueness_of :title
  
  validates_numericality_of :capital_required, :ipo_price, :share_percent
  
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }
  
  protected
  
  def validate
    errors.add(:share_percent, "Must be a percentage (0 - 100)") if share_percent.nil? || share_percent < 0 || share_percent > 100
  end
  
end
