class Feed < ActiveRecord::Base
  belongs_to :feed_item
  belongs_to :profile
  attr_immutable :id, :profile_id, :feed_item_id
end








# == Schema Information
#
# Table name: feeds
#
#  id           :integer(4)      not null, primary key
#  profile_id   :integer(4)
#  feed_item_id :integer(4)
#

