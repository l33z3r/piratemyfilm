class AddRatingDataToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :member_rating, :integer, :default => 0
    add_column :projects, :admin_rating, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :member_rating
    remove_column :projects, :admin_rating
  end
end
