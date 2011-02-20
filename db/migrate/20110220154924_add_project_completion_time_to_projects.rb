class AddProjectCompletionTimeToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :completion_date, :datetime
  end

  def self.down
    remove_column :projects, :completion_date
  end
end
