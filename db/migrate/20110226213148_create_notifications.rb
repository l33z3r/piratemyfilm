class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :notification_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
