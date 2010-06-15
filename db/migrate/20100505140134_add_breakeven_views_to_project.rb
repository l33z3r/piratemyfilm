class AddBreakevenViewsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :breakeven_views, :float
  end

  def self.down
    remove_column :projects, :breakeven_views
  end
end
