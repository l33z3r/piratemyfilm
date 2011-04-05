class AddWarnPointsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :warn_points, :integer, :default => 0
    add_column :projects, :percent_bad_shares, :integer, :default => 0
  end

  def self.down
    remove_column :users, :warn_points
    remove_column :projects, :percent_bad_shares
  end
end
