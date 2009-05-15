class AddAmountToProjectSubscription < ActiveRecord::Migration
  def self.up
    add_column :project_subscriptions, :amount, :decimal, :default => 1
  end

  def self.down
    remove_column :project_subscriptions, :amount
  end
end
