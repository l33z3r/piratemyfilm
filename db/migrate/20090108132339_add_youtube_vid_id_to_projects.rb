class AddYoutubeVidIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :youtube_vid_id, :string
  end

  def self.down
    remove_column :projects, :youtube_vid_id
  end
end
