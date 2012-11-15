class BlogProjectMention < ActiveRecord::Base
  belongs_to :project
  belongs_to :blog
end







# == Schema Information
#
# Table name: blog_project_mentions
#
#  id         :integer(4)      not null, primary key
#  blog_id    :integer(4)
#  project_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

