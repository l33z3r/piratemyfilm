class AddInvoiceIdToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :bitpay_invoice_id, :string
    add_column :pmf_share_buyouts, :bitpay_invoice_id, :string
    add_column :projects, :bitpay_email, :string
    add_column :payment_windows, :bitpay_email, :string
  end

  def self.down
    remove_column :subscription_payments, :bitpay_invoice_id
    remove_column :pmf_share_buyouts, :bitpay_invoice_id
    remove_column :projects, :bitpay_email
    remove_column :payment_windows, :bitpay_email
  end
end
