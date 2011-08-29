class AddPaypalEmailToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :paypal_email, :string
  end

  def self.down
    remove_column :projects, :paypal_email
  end
end
