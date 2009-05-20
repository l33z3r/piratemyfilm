class CreateAdminProjectRatings < ActiveRecord::Migration
  def self.up
    create_table :admin_project_ratings do |t|
      t.integer :project_id
      t.integer :rating
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_project_ratings
  end
end
