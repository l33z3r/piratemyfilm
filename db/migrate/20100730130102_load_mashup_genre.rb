class LoadMashupGenre < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Mashup")
  end

  def self.down
    Genre.find_by_title(:title => "Mashup").destroy!
  end
end
