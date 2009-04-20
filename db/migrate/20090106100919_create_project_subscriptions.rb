class CreateProjectSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :project_subscriptions do |t|
      t.integer :project_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_subscriptions
  end
end
