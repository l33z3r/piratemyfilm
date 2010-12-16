class CreateUserTalents < ActiveRecord::Migration
  def self.up
    create_table :user_talents do |t|
      t.integer :user_id
      t.string :talent_type
      t.timestamps
    end
  end

  def self.down
    drop_table :user_talents
  end
end
