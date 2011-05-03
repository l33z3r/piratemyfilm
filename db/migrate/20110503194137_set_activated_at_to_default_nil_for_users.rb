class SetActivatedAtToDefaultNilForUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :activated_at, :datetime, :default => nil
  end

  def self.down
  end
end
