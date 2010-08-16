class AddNumberPmfFundSharesHeldToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :pmf_fund_investment_share_amount, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :pmf_fund_investment_share_amount
  end
end
