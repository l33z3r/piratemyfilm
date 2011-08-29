require 'test_helper'

class ProjectFlaggingTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: project_flaggings
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  project_id :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

