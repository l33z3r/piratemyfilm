class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :membership_type
end








# == Schema Information
#
# Table name: memberships
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  membership_type_id :integer(4)      default(1)
#  expires_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

