class ChangeDateFieldsInProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :premier_date
    remove_column :projects, :completion_date
    
    add_column :projects, :weeks_to_finish, :integer
  end

  def self.down
    add_column :projects, :premier_date, :datetime
    add_column :projects, :completion_date, :datetime
    
    remove_column :projects, :weeks_to_finsh
  end
end
