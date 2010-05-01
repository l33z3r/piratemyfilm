class AddMockumentaryToGenres < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Mockumentary")
  end

  def self.down
    Genre.find_by_title(:title => "Mockumentary").destroy!
  end
end