require 'test_helper'

class ProjectChangeInfoOneDayTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: project_change_info_one_days
#
#  id           :integer(4)      not null, primary key
#  share_amount :integer(4)      default(0)
#  share_change :integer(4)      default(0)
#  project_id   :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

