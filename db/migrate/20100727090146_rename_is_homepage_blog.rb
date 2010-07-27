class RenameIsHomepageBlog < ActiveRecord::Migration
  def self.up
    rename_column :blogs, :is_homepage_blog, :is_admin_blog

    Blog.find(:all).each do |blog|
      blog.update_attributes(:is_admin_blog => false)
    end
  end

  def self.down
    rename_column :blogs, :is_admin_blog, :is_homepage_blog
  end
end
