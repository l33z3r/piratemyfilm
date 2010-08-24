class CreatePmfFundSubscriptionHistories < ActiveRecord::Migration
  def self.up
    create_table :pmf_fund_subscription_histories do |t|
      t.integer :project_id
      t.integer :amount
      t.timestamps
    end
  end

  def self.down
    drop_table :pmf_fund_subscription_histories
  end
end
