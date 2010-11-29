class CreateSubscriptionPayments < ActiveRecord::Migration
  def self.up
    create_table :subscription_payments do |t|
      t.integer :payment_window_id
      t.integer :project_id
      t.integer :user_id
      t.integer :share_amount
      t.float :share_price
      t.string :status#pending, paid, defaulted
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_payments
  end
end
