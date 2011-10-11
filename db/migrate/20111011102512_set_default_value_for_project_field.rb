class SetDefaultValueForProjectField < ActiveRecord::Migration
  def self.up
    change_column :projects, :pmf_fund_investment_percentage, :integer, :default => 0
  end

  def self.down
  end
end
