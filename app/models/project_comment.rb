# == Schema Information
# Schema version: 20100528091908
#
# Table name: project_comments
#
#  id         :integer(4)    not null, primary key
#  body       :text          
#  user_id    :integer(4)    
#  project_id :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class ProjectComment < ActiveRecord::Base
  #added by Paul, all

  belongs_to :project
  belongs_to :user
end
