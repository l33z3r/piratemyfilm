# == Schema Information
# Schema version: 20110110160522
#
# Table name: pmf_share_buyouts
#
#  id           :integer(4)    not null, primary key
#  project_id   :integer(4)    
#  user_id      :integer(4)    
#  share_amount :integer(4)    
#  share_price  :float         
#  status       :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class PmfShareBuyout < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  #pending means pending verification
  @@PAYMENT_STATUSES = ["Open", "Pending", "Denied", "Verified"]

  def payment_amount
    share_amount * share_price
  end

  def open?
    status == "Open"
  end

  def pending?
    status == "Pending"
  end

  def denied?
    status == "Denied"
  end

  def verified?
    status == "Verified"
  end

  def self.all_open
    find(:all, :conditions => "status = 'Open'")
  end

  def self.all_pending
    find(:all, :conditions => "status = 'Pending'")
  end

  def self.all_denied
    find(:all, :conditions => "status = 'Denied'")
  end

  def self.all_verified
    find(:all, :conditions => "status = 'Verified'")
  end
end
