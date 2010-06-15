class AddProducerFeeAndRecyclePercentToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :producer_fee_percent, :integer
    add_column :projects, :capital_recycled_percent, :integer
  end

  def self.down
    remove_column :projects, :producer_fee_percent
    remove_column :projects, :capital_recycled_percent
  end
end
