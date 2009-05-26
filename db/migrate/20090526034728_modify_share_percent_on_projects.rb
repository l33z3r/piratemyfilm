class ModifySharePercentOnProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :share_percent
    add_column    :projects, :share_percent_downloads, :decimal, :scale => 0, :precision => 3
    add_column    :projects, :share_percent_ads, :decimal, :scale => 0, :precision => 3
  end

  def self.down
    add_column    :projects, :share_percent, :decimal, :scale => 0, :precision => 3
    remove_column :projects, :share_percent_downloads
    remove_column :projects, :share_percent_ads
  end
end
