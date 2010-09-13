class AddSpecToGenres < ActiveRecord::Migration
  def self.up
    Genre.create(:title => "Spec")
    Genre.create(:title => "Political")
  end

  def self.down
    Genre.find_by_title("Spec").destroy
    Genre.find_by_title("Political").destroy
  end
end
