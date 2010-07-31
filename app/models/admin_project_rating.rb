# == Schema Information
# Schema version: 20100730130102
#
# Table name: admin_project_ratings
#
#  id         :integer(4)    not null, primary key
#  project_id :integer(4)    
#  rating     :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class AdminProjectRating < ActiveRecord::Base
  belongs_to :project
  
  @@MAX_RATING = 10

  validates_numericality_of :rating
  validates_inclusion_of :rating, :in => 1..@@MAX_RATING

  def self.max_rating
    @@MAX_RATING
  end

  @@ratings_map = {
    1 => "NR", 2 => "C-", 3 => "C", 4 => "C+", 5 => "B-",
    6 => "B", 7 => "B+", 8 => "A-", 9 => "A", 10 => "A+"
  }

  def self.rating_select_opts
    @ratings_select_opts = []

    @@ratings_map.each {  |key, value|
      @ratings_select_opts << [value, key.to_s]
    }

    @ratings_select_opts.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @ratings_select_opts
  end

  def rating_symbol
    @@ratings_map[rating]
  end

  def self.ratings_map
    @@ratings_map
  end

end
