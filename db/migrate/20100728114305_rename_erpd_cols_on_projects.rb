class RenameErpdColsOnProjects < ActiveRecord::Migration
  def self.up
    rename_column :projects, :producer_erpd, :producer_dividend
    rename_column :projects, :shareholder_erpd, :shareholder_dividend

    add_column :projects, :fund_dividend, :integer
  end

  def self.down
    rename_column :projects, :producer_dividend, :producer_erpd
    rename_column :projects, :shareholder_dividend, :shareholder_erpd

    remove_column :projects, :fund_dividend
  end
end
