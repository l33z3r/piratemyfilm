class MemberRating < ActiveRecord::Base
  belongs_to :member, :class_name => "User", :foreign_key => "member_id"
  
  has_many :member_rating_histories, :dependent => :destroy

  @@MAX_RATING = 5

  validates_numericality_of :average_rating
  validates_inclusion_of :average_rating, :in => 1..@@MAX_RATING

  def self.max_rating
    @@MAX_RATING
  end

  @@ratings_map = {
    1 => "1", 2 => "2", 3 => "3", 4 => "4", 5 => "5"
  }

  def self.rating_select_opts
    @ratings_select_opts = []

    @@ratings_map.each {  |key, value|
      @ratings_select_opts << [value, key.to_s]
    }

    @ratings_select_opts.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @ratings_select_opts.reverse!

    @ratings_select_opts
  end

  def rating_symbol
    @@ratings_map[average_rating]
  end

  def self.ratings_map
    @@ratings_map
  end
end








# == Schema Information
#
# Table name: member_ratings
#
#  id             :integer(4)      not null, primary key
#  member_id      :integer(4)
#  average_rating :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

