class AddCountsAsWarnPointToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :counts_as_warn_point, :boolean, :default => false
  end

  def self.down
    remove_column :subscription_payments, :counts_as_warn_point
  end
end
