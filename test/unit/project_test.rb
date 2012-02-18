require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase

  load_all_fixtures
  
  context 'A Project instance' do
    
  end
  
end




# == Schema Information
#
# Table name: projects
#
#  id                               :integer(4)      not null, primary key
#  owner_id                         :integer(4)
#  title                            :string(255)
#  producer_name                    :string(255)
#  synopsis                         :text
#  genre_id                         :integer(4)
#  description                      :text
#  cast                             :text
#  web_address                      :string(255)
#  ipo_price                        :decimal(10, 2)
#  percent_funded                   :integer(3)
#  icon                             :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  youtube_vid_id                   :string(255)
#  status                           :string(255)     default("Funding")
#  project_length                   :integer(4)      default(0)
#  share_percent_downloads          :integer(3)
#  share_percent_ads                :integer(3)
#  downloads_reserved               :integer(10)     default(0)
#  downloads_available              :integer(10)     default(0)
#  capital_required                 :integer(12)
#  rated_at                         :datetime
#  is_deleted                       :boolean(1)      default(FALSE)
#  deleted_at                       :datetime
#  member_rating                    :integer(4)      default(0)
#  admin_rating                     :integer(4)      default(0)
#  director                         :string(255)
#  writer                           :string(255)
#  exec_producer                    :string(255)
#  producer_fee_percent             :integer(4)
#  capital_recycled_percent         :integer(4)
#  share_percent_ads_producer       :integer(4)      default(0)
#  producer_dividend                :float           default(0.0)
#  shareholder_dividend             :float           default(0.0)
#  symbol                           :string(255)
#  fund_dividend                    :float           default(0.0)
#  pmf_fund_investment_percentage   :integer(4)      default(0)
#  green_light                      :datetime
#  director_photography             :string(255)
#  editor                           :string(255)
#  pmf_fund_investment_share_amount :integer(4)      default(0)
#  project_payment_status           :string(255)
#  fully_funded_time                :datetime
#  completion_date                  :datetime
#  watch_url                        :string(255)
#  premier_date                     :date
#  percent_bad_shares               :integer(4)      default(0)
#  main_video                       :string(255)
#  daily_percent_move               :integer(4)      default(0)
#  paypal_email                     :string(255)
#  yellow_light                     :datetime
#  actors                           :string(255)
#  bitpay_email                     :string(255)
#

