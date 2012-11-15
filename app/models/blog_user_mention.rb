class BlogUserMention < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
end







# == Schema Information
#
# Table name: blog_user_mentions
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  blog_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

