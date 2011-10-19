class AddBlogRebuzzIdToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :blog_rebuzz_id, :integer
  end

  def self.down
    remove_column :blogs, :blog_rebuzz_id
  end
end
