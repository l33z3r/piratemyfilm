class AddDailyPercentMoveToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :daily_percent_move, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :daily_percent_move
  end
end
