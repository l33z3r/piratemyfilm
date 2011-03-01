class Admin::HomeController < Admin::AdminController

  def index
    @signups_yesterday = User.find(:all, :conditions => ['created_at > :date1 and created_at < :date2', 
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size

    @projects_created_yesterday = Project.find(:all, :conditions => ['created_at > :date1 and created_at < :date2',
        {:date1 => 2.days.ago.midnight, :date2 => 1.day.ago.midnight}]).size
  end

  private

  def set_selected_tab
    @selected_tab_name = "admin_stats"
  end
  
end
