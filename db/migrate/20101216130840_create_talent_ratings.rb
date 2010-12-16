class CreateTalentRatings < ActiveRecord::Migration
  def self.up
    create_table :talent_ratings do |t|
      t.integer :user_talent_id
      t.integer :average_rating
      t.timestamps
    end
  end

  def self.down
    drop_table :talent_ratings
  end
end
