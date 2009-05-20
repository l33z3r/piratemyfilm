class ProjectRating < ActiveRecord::Base
  belongs_to :project
  has_many :project_rating_histories

  @@MAX_RATING = 10

  validates_numericality_of :average_rating
  validates_inclusion_of :average_rating, :in => 1..@@MAX_RATING
  
  def self.max_rating
    @@MAX_RATING
  end
end
