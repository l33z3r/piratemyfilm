class PmfFundSubscriptionHistory < ActiveRecord::Base

  belongs_to :project
  
  def self.latest_for_user_followings user

    @project_ids = []

    user.followed_projects.each do |project|
      @project_ids << project.id
    end

    return [] if @project_ids.size == 0

    find(:all, :include => :project, :conditions => "projects.is_deleted = false and projects.symbol is not null and projects.id in (#{@project_ids.join(",")})",
      :order => "pmf_fund_subscription_histories.created_at desc")
  end

  def self.latest
    find(:all, :include => :project, :conditions => "projects.is_deleted = false and projects.symbol is not null",
      :order => "pmf_fund_subscription_histories.created_at desc")
  end
  
end








# == Schema Information
#
# Table name: pmf_fund_subscription_histories
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  amount     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

