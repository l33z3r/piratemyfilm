# == Schema Information
# Schema version: 20101216130905
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
  has_many :pending_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Pending' or status = 'Open'"
  has_many :completed_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Paid'"
  has_many :defaulted_payments, :class_name => "SubscriptionPayment", :foreign_key => "payment_window_id", :conditions => "status = 'Defaulted'"

  validates_format_of :paypal_email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :on => :create, :message=>"Invalid email address."

  @@PAYMENT_STATUSES = ["Active", "Successful", "Failed"]

  def open?
    status == "Active"
  end
  
  def amount_payment_collected
    @amount = 0

    completed_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def amount_payment_pending
    @amount = 0

    pending_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def amount_defaulted_payment
    @amount = 0

    defaulted_payments.each do |sp|
      @amount += (sp.share_amount * sp.share_price)
    end

    @amount
  end

  def all_payments_collected?
    amount_payment_pending == 0
  end
end
