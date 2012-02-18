require 'test_helper'

class SubscriptionPaymentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end





# == Schema Information
#
# Table name: subscription_payments
#
#  id                   :integer(4)      not null, primary key
#  payment_window_id    :integer(4)
#  project_id           :integer(4)
#  user_id              :integer(4)
#  share_amount         :integer(4)
#  share_price          :float
#  status               :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  counts_as_warn_point :boolean(1)      default(FALSE)
#  reused_by_payment_id :integer(4)
#  bitpay_invoice_id    :string(255)
#

