class ProjectFollowing < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
end








# == Schema Information
#
# Table name: project_followings
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

