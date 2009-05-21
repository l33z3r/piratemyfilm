class ProjectRating < ActiveRecord::Base
  belongs_to :project
  has_many :project_rating_histories

  @@MAX_RATING = 10

  validates_numericality_of :average_rating
  validates_inclusion_of :average_rating, :in => 1..@@MAX_RATING

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
      logger.debug "#{key}!"
      @ratings_select_opts << [value, key]
    }

    @ratings_select_opts.sort
  end

  def rating_symbol
    @@ratings_map[average_rating]
  end
  
end
