class AddPmfFundInvestmentPercentageToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :pmf_fund_investment_percentage, :integer
  end

  def self.down
    remove_column :projects, :pmf_fund_investment_percentage
  end
end
