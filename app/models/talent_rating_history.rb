class TalentRatingHistory < ActiveRecord::Base
  belongs_to :talent_rating
  belongs_to :user
end

# == Schema Information
#
# Table name: talent_rating_histories
#
#  id               :integer(4)      not null, primary key
#  talent_rating_id :integer(4)
#  user_id          :integer(4)
#  rating           :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

