class CreateMemberRatings < ActiveRecord::Migration
  def self.up
    create_table :member_ratings do |t|
      t.integer :member_id
      t.integer :average_rating
      t.timestamps
    end
  end

  def self.down
    drop_table :member_ratings
  end
end
