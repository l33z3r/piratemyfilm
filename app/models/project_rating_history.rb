class ProjectRatingHistory < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :project_rating
end

# == Schema Information
#
# Table name: project_rating_histories
#
#  id                :integer(4)      not null, primary key
#  project_id        :integer(4)
#  user_id           :integer(4)
#  rating            :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  project_rating_id :integer(4)
#

