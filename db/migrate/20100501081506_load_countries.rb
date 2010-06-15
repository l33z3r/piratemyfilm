class LoadCountries < ActiveRecord::Migration
  def self.up

    down

    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "countries")

  end

  def self.down
    Country.delete_all
  end
end
