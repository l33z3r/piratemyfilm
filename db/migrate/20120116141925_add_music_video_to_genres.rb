class AddMusicVideoToGenres < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Music Video")
  end

  def self.down
    Genre.find_by_title("Music Video").destroy
  end
end
