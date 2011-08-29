require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  notification_type_id :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#

