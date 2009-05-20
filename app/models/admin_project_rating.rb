class AdminProjectRating < ActiveRecord::Base
  belongs_to :project
  
  @@MAX_RATING = 10

  validates_numericality_of :rating
  validates_inclusion_of :rating, :in => 1..@@MAX_RATING

  def self.max_rating
    @@MAX_RATING
  end
end
