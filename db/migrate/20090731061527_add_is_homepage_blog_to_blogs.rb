class AddIsHomepageBlogToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :is_homepage_blog, :boolean, :default => false
  end

  def self.down
    remove_column :blogs, :is_homepage_blog
  end
end
