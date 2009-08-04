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
  
  @@MAX_SUBSCRIPTIONS = { :per_project => 5, :projects => 5 }
  
  def self.max_subscriptions 
      @@MAX_SUBSCRIPTIONS[:per_project]
  end

  def self.max_project_subscriptions
      @@MAX_SUBSCRIPTIONS[:projects]
  end
  
end
