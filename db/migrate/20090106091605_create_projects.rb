class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer  "owner_id"
      t.string   "title"      
      t.string   "producer_name"
      t.text     "synopsis"
      t.integer  "genre_id"
      t.text     "description"
      t.text     "cast"
      t.string   "web_address"
      t.decimal  "capital_required", :scale => 2, :precision => 12
      t.decimal  "ipo_price", :scale => 2, :precision => 10
      t.decimal  "share_percent", :scale => 0, :precision => 3
      t.decimal  "percent_funded", :scale => 0, :precision => 3
      t.string   "icon"
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
