class AddNewsFeatureToGenre < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "News Feature")
  end

  def self.down
    Genre.find_by_title("News Feature").destroy
  end
end
