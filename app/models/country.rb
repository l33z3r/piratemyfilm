# == Schema Information
# Schema version: 20100720120616
#
# Table name: countries
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)   not null
#  created_at :datetime      
#  updated_at :datetime      
#

class Country < ActiveRecord::Base

  has_many :profiles

  def self.all_in_order
    find(:all, :order=>'name ASC')
  end

  def self.all_in_order_filtered countries
    options = {:order=>'name ASC'}

    if !countries.empty?
      options = options.merge!({:conditions => ["id not in (?)", countries.collect{|c|c.id}]})
    end

    find(:all, options)
  end

  def self.for_select
    [['Please Select','2']] + all_in_order.collect {|c| [ c.name, c.id ] }
  end

  def self.for_select_filtered countries
    all_in_order_filtered(countries).collect {|c| [ c.name, c.id ] }
  end

  def to_s
    self.name
  end

end
