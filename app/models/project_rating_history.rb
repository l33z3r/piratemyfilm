# == Schema Information
# Schema version: 20100528091908
#
# Table name: project_rating_histories
#
#  id         :integer(4)    not null, primary key
#  project_id :integer(4)    
#  user_id    :integer(4)    
#  rating     :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class ProjectRatingHistory < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :project_rating
end
