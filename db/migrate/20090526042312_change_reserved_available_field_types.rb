class ChangeReservedAvailableFieldTypes < ActiveRecord::Migration
  def self.up
    remove_column :projects, :downloads_reserved
    remove_column :projects, :downloads_available
    add_column    :projects, :downloads_reserved, :decimal, :default => 0
    add_column    :projects, :downloads_available, :decimal, :default => 0
  end

  def self.down
    remove_column :projects, :downloads_reserved
    remove_column :projects, :downloads_available
    add_column    :projects, :downloads_reserved, :decimal, :scale => 2, :precision => 12
    add_column    :projects, :downloads_reserved, :decimal, :scale => 2, :precision => 12
  end
end
