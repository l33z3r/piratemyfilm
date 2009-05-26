class ModifyCapitalRequiredOnProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :capital_required
    add_column :projects, :capital_required, :decimal, :scale => 0, :precision => 12
  end

  def self.down
    remove_column :projects, :capital_required
    add_column :projects, :capital_required, :decimal, :scale => 2, :precision => 12
  end
end
