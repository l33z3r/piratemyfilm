# == Schema Information
# Schema version: 20090526045351
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
  
end
