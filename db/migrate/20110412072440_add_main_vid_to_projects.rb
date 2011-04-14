class AddMainVidToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :main_video, :string
  end

  def self.down
    remove_column :projects, :main_video
  end
end
