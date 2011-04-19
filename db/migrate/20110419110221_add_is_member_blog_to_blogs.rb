class AddIsMemberBlogToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :is_member_blog, :boolean, :default => false
  end

  def self.down
    remove_column :blogs, :is_member_blog
  end
end
