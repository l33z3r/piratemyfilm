require 'test_helper'

class PaymentWindowTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end


# == Schema Information
#
# Table name: payment_windows
#
#  id           :integer(4)      not null, primary key
#  project_id   :integer(4)
#  paypal_email :string(255)
#  close_date   :date
#  status       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  bitpay_email :string(255)
#

