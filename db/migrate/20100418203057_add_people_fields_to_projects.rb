class AddPeopleFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :director, :string
    add_column :projects, :writer, :string
    add_column :projects, :exec_producer, :string
  end

  def self.down
    remove_column :projects, :directory
    remove_column :projects, :writer
    remove_column :projects, :exec_producer
  end
end
