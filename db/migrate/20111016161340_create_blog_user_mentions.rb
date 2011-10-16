class CreateBlogUserMentions < ActiveRecord::Migration
  def self.up
    create_table :blog_user_mentions do |t|
      t.integer :user_id
      t.integer :blog_id
      t.timestamps
    end
  end

  def self.down
    drop_table :blog_user_mentions
  end
end
