class AddReleaseFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :watch_url, :string
    add_column :projects, :premier_date, :date
  end

  def self.down
    remove_column :projects, :watch_url
    remove_column :projects, :premier_date
  end
end
