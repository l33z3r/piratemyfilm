# == Schema Information
# Schema version: 20090526045351
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
  
  @@MAX_SUBSCRIPTIONS = 5
  
  def self.max_subscriptions 
    @@MAX_SUBSCRIPTIONS
  end
  
end
