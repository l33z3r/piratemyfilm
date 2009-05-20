class CreateProjectRatingHistories < ActiveRecord::Migration
  def self.up
    create_table :project_rating_histories do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :project_rating_histories
  end
end
