# == Schema Information
# Schema version: 20101115184046
#
# Table name: payment_windows
#
#  id           :integer(4)    not null, primary key
#  project_id   :integer(4)    
#  paypal_email :string(255)   
#  close_date   :date          
#  status       :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class PaymentWindow < ActiveRecord::Base
  belongs_to :project
  has_many :subscription_payments

  validates_format_of :paypal_email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :on => :create, :message=>"Invalid email address."

  @@PAYMENT_STATUSES = ["Active", "Successful", "Failed"]

  def amount_payment_collected
    @amount = 0

    subscription_payments.each do |sp|
      if sp.status == "Paid"
        @amount += (sp.share_amount * sp.share_price)
      end
    end

    @amount
  end
end
