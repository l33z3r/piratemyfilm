class BlogComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
  validates_presence_of :body
end


# == Schema Information
#
# Table name: blog_comments
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  blog_id    :integer(4)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

