class ProjectUserTalent < ActiveRecord::Base
  belongs_to :project
  belongs_to :user_talent
  
  has_many :blogs
end





# == Schema Information
#
# Table name: project_user_talents
#
#  id             :integer(4)      not null, primary key
#  user_talent_id :integer(4)
#  project_id     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

