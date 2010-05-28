class AddMinimumFundingToMembershipType < ActiveRecord::Migration
  def self.up
    add_column :membership_types, :min_funding_limit_per_project, :integer, :default => 0
  end

  def self.down
    remove_column :memebership_types, :min_funding_limit_per_project
  end
end
