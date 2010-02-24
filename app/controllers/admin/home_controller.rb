class Admin::HomeController < Admin::AdminController

  def index
    @user_count = User.find(:all).size
    @signups_yesterday = User.find(:all, :conditions => ['created_at > :date1 and created_at < :date2', 
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size
  end
  
end
