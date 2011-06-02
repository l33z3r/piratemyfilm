class ProjectUserTalent < ActiveRecord::Base
  belongs_to :project
  belongs_to :user_talent
  
  has_many :blogs
end
