require 'test_helper'

class UserTalentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

# == Schema Information
#
# Table name: user_talents
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  talent_type :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

