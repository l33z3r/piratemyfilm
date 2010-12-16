class CreateTalentRatingHistories < ActiveRecord::Migration
  def self.up
    create_table :talent_rating_histories do |t|
      t.integer :talent_rating_id
      t.integer :user_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :talent_rating_histories
  end
end
