class AddFundedTimeToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :fully_funded_time, :timestamp
  end

  def self.down
    remove_column :projects, :fully_funded_time
  end
end
