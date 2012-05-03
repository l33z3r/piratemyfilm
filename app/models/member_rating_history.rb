class MemberRatingHistory < ActiveRecord::Base
  belongs_to :member, :class_name => "User", :foreign_key => "member_id"
  belongs_to :rater, :class_name => "User", :foreign_key => "rater_id"
  belongs_to :member_rating
end







# == Schema Information
#
# Table name: member_rating_histories
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  rater_id   :integer(4)
#  rating     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

