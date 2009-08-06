class AddIsDeletedToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :is_deleted, :boolean, :default => false
    add_column :projects, :deleted_at, :datetime
  end

  def self.down
    remove_column :projects, :is_deleted
    remove_column :projects, :deleted_at
  end
end
