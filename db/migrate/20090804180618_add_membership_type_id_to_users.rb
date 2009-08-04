class AddMembershipTypeIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :membership_type_id, :boolean, :default => false
  end

  def self.down
    remove_column :users, :membership_type_id
  end
end
