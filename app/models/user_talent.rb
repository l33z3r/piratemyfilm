# == Schema Information
# Schema version: 20101216130905
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
  has_many :talent_ratings

  @@TALENT_TYPES_MAP = {
  1 => "director",
  2 => "writer",
  3 => "exec_producer",
  4 => "director_photography",
  5 => "editor"}

  validates_inclusion_of :talent_type, :in => @@TALENT_TYPES_MAP

  def self.talent_types_map
    @@TALENT_TYPES_MAP
  end
  
end
