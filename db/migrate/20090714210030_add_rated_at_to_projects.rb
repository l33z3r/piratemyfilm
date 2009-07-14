class AddRatedAtToProjects < ActiveRecord::Migration
  #added by Paul, all
  
  def self.up
    add_column :projects, :rated_at, :datetime
  end

  def self.down
    remove_column :projects, :rated_at
  end
end
