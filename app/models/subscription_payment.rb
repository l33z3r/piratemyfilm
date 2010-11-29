# == Schema Information
# Schema version: 20101115184046
#
# Table name: subscription_payments
#
#  id                :integer(4)    not null, primary key
#  payment_window_id :integer(4)    
#  project_id        :integer(4)    
#  user_id           :integer(4)    
#  share_amount      :float         
#  share_price       :integer(4)    
#  status            :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class SubscriptionPayment < ActiveRecord::Base
  belongs_to :payment_window
  belongs_to :user
  belongs_to :project
  
  has_many :project_subscriptions

  @@PAYMENT_STATUSES = ["Pending", "Paid", "Defaulted"]

  def payment_amount
    share_amount * share_price
  end

  def paid?
    status == "Paid"
  end
end
