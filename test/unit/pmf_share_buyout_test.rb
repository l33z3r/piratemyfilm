require 'test_helper'

class PmfShareBuyoutTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end


# == Schema Information
#
# Table name: pmf_share_buyouts
#
#  id                :integer(4)      not null, primary key
#  project_id        :integer(4)
#  user_id           :integer(4)
#  share_amount      :integer(4)
#  share_price       :float
#  status            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  bitpay_invoice_id :string(255)
#

