class LoadTrailerGenre < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Trailer")
  end

  def self.down
    Genre.find_by_title("Trailer").destroy
  end
end
