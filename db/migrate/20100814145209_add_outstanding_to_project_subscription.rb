class AddOutstandingToProjectSubscription < ActiveRecord::Migration
  def self.up
    add_column :project_subscriptions, :outstanding, :boolean, :default => false
  end

  def self.down
    remove_column :project_subscriptions, :outstanding
  end
end
