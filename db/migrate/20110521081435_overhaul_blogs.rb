class OverhaulBlogs < ActiveRecord::Migration
  def self.up
    remove_column :blogs, :is_member_blog
    add_column :users, :following_mkc_blogs, :boolean, :default => false
    add_column :users, :following_admin_blogs, :boolean, :default => false
    
    #set the profile ids of mkc and admin blogs to nil
    Blog.find(:all, :conditions => "guid is not null or is_admin_blog = 1").each do |blog|
      blog.profile_id = nil
      blog.save
    end
    
  end

  def self.down
    add_column :blogs, :is_member_blog, :boolean, :default => false
    remove_column :users, :following_mkc_blogs
    remove_column :users, :following_admin_blogs
  end
end
