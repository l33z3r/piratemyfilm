class LoadAdditionalGenres < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Not Sure")
  end

  def self.down
    Genre.find_by_title(:title => "Not Sure").destroy!
  end
end

