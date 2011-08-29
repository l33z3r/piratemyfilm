require 'test_helper'

class MemberRatingHistoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: member_rating_histories
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  rater_id   :integer(4)
#  rating     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

