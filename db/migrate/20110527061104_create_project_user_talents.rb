class CreateProjectUserTalents < ActiveRecord::Migration
  def self.up
    create_table :project_user_talents do |t|
      t.integer :user_talent_id
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_user_talents
  end
end
