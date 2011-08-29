require 'test_helper'

class TalentRatingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: talent_ratings
#
#  id             :integer(4)      not null, primary key
#  user_talent_id :integer(4)
#  average_rating :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

