class AddYellowLightToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :yellow_light, :datetime
  end

  def self.down
    remove_column :projects, :yellow_light
  end
end
