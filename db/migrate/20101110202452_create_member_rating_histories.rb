class CreateMemberRatingHistories < ActiveRecord::Migration
  def self.up
    create_table :member_rating_histories do |t|
      t.integer :member_id
      t.integer :rater_id
      t.integer :rating
      t.timestamps
    end

    add_column :users, :member_rating, :integer, :default => 0
  end

  def self.down
    drop_table :member_rating_histories
    remove_column :users, :member_rating
  end
end
