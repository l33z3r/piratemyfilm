require 'test_helper'

class ProjectFollowingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: project_followings
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

