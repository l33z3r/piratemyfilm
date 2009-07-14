class CreateProjectComments < ActiveRecord::Migration
  #added by Paul, all

  def self.up
    create_table :project_comments do |t|
      t.text :body
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :project_comments
  end
end
