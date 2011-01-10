class AddTalentToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :producer_talent_id, :integer
    add_column :projects, :director_talent_id, :integer
    add_column :projects, :writer_talent_id, :integer
    add_column :projects, :exec_producer_talent_id, :integer
    add_column :projects, :director_photography_talent_id, :integer
    add_column :projects, :editor_talent_id, :integer
  end

  def self.down
    remove_column :projects, :producer_talent_id
    remove_column :projects, :director_talent_id
    remove_column :projects, :writer_talent_id
    remove_column :projects, :exec_producer_talent_id
    remove_column :projects, :director_photography_talent_id
    remove_column :projects, :editor_talent_id
  end
end
