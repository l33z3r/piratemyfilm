class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :membership_type
end
