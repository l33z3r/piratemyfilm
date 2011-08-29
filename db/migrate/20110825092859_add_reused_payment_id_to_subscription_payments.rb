class AddReusedPaymentIdToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :reused_by_payment_id, :integer
  end

  def self.down
    remove_column :subscription_payments, :reused_by_payment_id
  end
end
