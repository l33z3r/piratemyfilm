class Genre < ActiveRecord::Base
  
  has_many :projects

  def self.default
    find_by_title("Not Sure")
  end

  def self.all_volumes_today
    @volumes = []

    Genre.all.each do |genre|
      @volumes << [genre, ProjectChangeInfoOneDay.today_volume_for_genre(genre)]
    end

    @volumes.sort! { |arr1, arr2|
      arr2[1].to_i.abs <=> arr1[1].to_i.abs
    }

    @volumes
  end
  
end





# == Schema Information
#
# Table name: genres
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

