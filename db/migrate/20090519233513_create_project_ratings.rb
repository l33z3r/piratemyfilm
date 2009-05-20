class CreateProjectRatings < ActiveRecord::Migration
  def self.up
    create_table :project_ratings do |t|
      t.integer :project_id
      t.integer :average_rating
      t.timestamps
    end
  end

  def self.down
    drop_table :project_ratings
  end
end
