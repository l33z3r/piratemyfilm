class AddCountryIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :country_id, :integer, :default => 1
  end

  def self.down
    remove_column :profiles, :country_id
  end
end
