class BlogUserMention < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog
end
