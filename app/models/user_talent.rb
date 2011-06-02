# == Schema Information
# Schema version: 20110521081435
#
# Table name: user_talents
#
#  id          :integer(4)    not null, primary key
#  user_id     :integer(4)    
#  talent_type :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class UserTalent < ActiveRecord::Base
  belongs_to :user
  has_one :talent_rating, :dependent => :destroy

  has_many :project_user_talents
  
  @@TALENT_TYPES_MAP = {
    1 => "director",
    2 => "writer",
    3 => "exec_producer",
    4 => "director_photography",
    5 => "editor",
    6 => "producer"}

  validates_inclusion_of :talent_type, :in => @@TALENT_TYPES_MAP.values

  def key
    @@TALENT_TYPES_MAP.invert[talent_type]
  end

  def label
    talent_type.humanize.titleize
  end

  def current_rating
    if talent_rating
      talent_rating.average_rating
    else
      0
    end
  end
  
  def self.filter_param_select_opts
    @filter_param_select_opts = []

    @@TALENT_TYPES_MAP.each {  |key, value|
      @filter_param_select_opts << [value.humanize.titleize, key.to_s]
    }

    @filter_param_select_opts << ["View Talents By", "0"]
    
    @filter_param_select_opts.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @filter_param_select_opts.reverse!

    @filter_param_select_opts
  end

  def self.talent_types_map
    @@TALENT_TYPES_MAP
  end

  def talent_rating_id
    if talent_rating
      return talent_rating.id
    else
      return nil
    end
  end

  def self.all_for_talent_type talent_type_name
    find(:all, :include => :talent_rating, :conditions => "talent_type = '#{talent_type_name}'",
      :order => "talent_ratings.average_rating desc")
  end

end
