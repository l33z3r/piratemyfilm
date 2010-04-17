class AddGuidToBlog < ActiveRecord::Migration
  def self.up
    add_column :blogs, :guid, :string
  end

  def self.down
    remove_column :blogs, :guid
  end
end
