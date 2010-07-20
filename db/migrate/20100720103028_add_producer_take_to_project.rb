class AddProducerTakeToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :share_percent_ads_producer, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :share_percent_ads_producer
  end
end
