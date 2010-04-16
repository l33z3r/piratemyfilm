class AddNumCommentsToBlog < ActiveRecord::Migration
  def self.up
    add_column :blogs, :num_wp_comments, :integer, :default => 0
    add_column :blogs, :wp_comments_link, :string
  end

  def self.down
    remove_column :blogs, :num_wp_comments
    remove_column :blogs, :wp_comments_link
  end
end
