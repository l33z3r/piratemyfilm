class AddGreenLightToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :green_light, :datetime
  end

  def self.down
    remove_column :projects, :green_light
  end
end
