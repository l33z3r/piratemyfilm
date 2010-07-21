class AddSymbolToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :symbol, :string

    #make all existing project symbols blank strings so they are public
    Project.find(:all).each do |p|
      p.symbol = ""
      p.save(false)
    end
    
  end

  def self.down
    remove_column :projects, :symbol
  end
end
