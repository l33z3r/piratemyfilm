class CreateBlogProjectMentions < ActiveRecord::Migration
  def self.up
    create_table :blog_project_mentions do |t|
      t.integer :blog_id
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :blog_project_mentions
  end
end
