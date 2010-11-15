class CreatePaymentWindows < ActiveRecord::Migration
  def self.up
    create_table :payment_windows do |t|
      t.integer :project_id
      t.string :paypal_email
      t.date :close_date
      t.string :status#active, success, fail
      t.timestamps
    end

    add_column :projects, :project_payment_status, :string
    add_column :project_subscriptions, :subscription_payment_id, :integer
  end

  def self.down
    remove_column :projects, :project_payment_status
    remove_column :project_subscriptions, :subscription_payment_id
    
    drop_table :payment_windows
  end
end
