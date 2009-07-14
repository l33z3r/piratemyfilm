class ProjectComment < ActiveRecord::Base
  #added by Paul, all

  belongs_to :project
  belongs_to :user
end
