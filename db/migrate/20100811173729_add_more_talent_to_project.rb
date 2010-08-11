class AddMoreTalentToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :director_photography, :string
    add_column :projects, :editor, :string
  end

  def self.down
    remove_column :projects, :director_photography
    remove_column :projects, :editor
  end
end
