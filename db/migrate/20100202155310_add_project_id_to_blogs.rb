class AddProjectIdToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :project_id, :integer, :default => nil
  end

  def self.down
    remove_column :blogs, :project_id
  end
end
