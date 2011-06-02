# == Schema Information
# Schema version: 20110521081435
#
# Table name: subscription_payments
#
#  id                :integer(4)    not null, primary key
#  payment_window_id :integer(4)    
#  project_id        :integer(4)    
#  user_id           :integer(4)    
#  share_amount      :integer(4)    
#  share_price       :float         
#  status            :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class SubscriptionPayment < ActiveRecord::Base
  belongs_to :payment_window
  belongs_to :user
  belongs_to :project
  
  has_many :project_subscriptions

  @@PAYMENT_STATUSES = ["Open", "Pending", "Paid", "Defaulted"]

  def payment_amount
    share_amount * share_price
  end

  def open?
    status == "Open"
  end

  def pending?
    status == "Pending"
  end

  def paid?
    status == "Paid"
  end

  def defaulted?
    status == "Defaulted"
  end
end
