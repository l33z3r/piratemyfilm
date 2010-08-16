# == Schema Information
# Schema version: 20100814145209
#
# Table name: genres
#
#  id         :integer(4)    not null, primary key
#  title      :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Genre < ActiveRecord::Base
  
  has_many :projects

  def self.default
    find_by_title("Not Sure")
  end
  
end
