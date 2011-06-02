class AddProjectUserTalentIdToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :project_user_talent_id, :integer
  end

  def self.down
    remove_column :blogs, :project_user_talent_id
  end
end
