class CreateMembershipTypes < ActiveRecord::Migration
  def self.up
    create_table :membership_types do |t|
      t.string :name
      t.integer :max_projects_listed
      t.integer :pc_limit
      t.integer :pc_project_limit
      t.integer :funding_limit_per_project
      t.timestamps
    end
  end

  def self.down
    drop_table :membership_types
  end
end
