class AddFundingColumnsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :downloads_reserved, :decimal, :scale => 2, :precision => 12
    add_column :projects, :downloads_available, :decimal, :scale => 2, :precision => 12
  end

  def self.down
    remove_column :projects, :downloads_reserved
    remove_column :projects, :downloads_available
  end
end
