class MemberRatingHistory < ActiveRecord::Base
  belongs_to :member, :class_name => "User", :foreign_key => "member_id"
  belongs_to :rater, :class_name => "User", :foreign_key => "rater_id"
  belongs_to :member_rating
end
