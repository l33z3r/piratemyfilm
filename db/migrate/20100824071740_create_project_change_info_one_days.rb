class CreateProjectChangeInfoOneDays < ActiveRecord::Migration
  def self.up
    create_table :project_change_info_one_days do |t|
      t.integer :share_amount, :default => 0
      t.integer :share_change, :default => 0
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_change_info_one_days
  end
end
