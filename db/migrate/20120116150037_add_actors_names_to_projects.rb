class AddActorsNamesToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :actors, :string
  end

  def self.down
    remove_column :projects, :actors
  end
end
