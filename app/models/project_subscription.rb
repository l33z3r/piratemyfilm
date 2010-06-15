# == Schema Information
# Schema version: 20100528091908
#
# Table name: project_subscriptions
#
#  id         :integer(4)    not null, primary key
#  project_id :integer(4)    
#  user_id    :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#  amount     :integer(10)   default(1)
#

class ProjectSubscription < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :project
  
end
