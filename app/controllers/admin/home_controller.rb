class Admin::HomeController < Admin::AdminController

  def index
    @num_pending_projects = Project.find(:all, :conditions => "rated_at is null and is_deleted = 0").size
    @user_count = User.find(:all).size
    @signups_yesterday = User.find(:all, :conditions => ['created_at > :date1 and created_at < :date2', 
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size
  end
  
end
