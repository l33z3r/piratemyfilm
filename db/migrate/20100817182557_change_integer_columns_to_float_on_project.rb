class ChangeIntegerColumnsToFloatOnProject < ActiveRecord::Migration
  def self.up
    change_column :projects, :producer_dividend, :float, :default => 0
    change_column :projects, :shareholder_dividend, :float, :default => 0
    change_column :projects, :fund_dividend, :float, :default => 0
  end

  def self.down
    change_column :projects, :producer_dividend, :integer, :default => 0
    change_column :projects, :shareholder_dividend, :integer, :default => 0
    change_column :projects, :fund_dividend, :integer, :default => 0
  end
end
