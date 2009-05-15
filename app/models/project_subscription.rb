class ProjectSubscription < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :project
  
  @@MAX_SUBSCRIPTIONS = 10
  
  def self.max_subscriptions 
    @@MAX_SUBSCRIPTIONS
  end
  
end
