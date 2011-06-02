# == Schema Information
# Schema version: 20110521081435
#
# Table name: talent_rating_histories
#
#  id               :integer(4)    not null, primary key
#  talent_rating_id :integer(4)    
#  user_id          :integer(4)    
#  rating           :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#

class TalentRatingHistory < ActiveRecord::Base
  belongs_to :talent_rating
  belongs_to :user
end
