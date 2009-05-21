class AddFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :status, :string, :default => "Funding"
    add_column :projects, :project_length, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :status
    remove_column :projects, :project_length
  end
end
