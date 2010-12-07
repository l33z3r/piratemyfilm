class CreatePmfShareBuyouts < ActiveRecord::Migration
  def self.up
    create_table :pmf_share_buyouts do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :share_amount
      t.float :share_price
      t.string :status#pending, paid, defaulted
      t.timestamps
    end
  end

  def self.down
    drop_table :pmf_share_buyouts
  end
end
