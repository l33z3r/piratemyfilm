class AddNewEstimatesToProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :breakeven_views
    add_column :projects, :producer_erpd, :integer
    add_column :projects, :shareholder_erpd, :integer
  end

  def self.down
    add_column :projects, :breakeven_views, :float
    remove_column :projects, :producer_erpd
    remove_column :projects, :shareholder_erpd
  end
end
