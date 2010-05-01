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
    all_in_order.collect {|c| [ c.name, c.id ] }
  end

  def self.for_select_filtered countries
    all_in_order_filtered(countries).collect {|c| [ c.name, c.id ] }
  end

  def to_s
    self.name
  end

end
