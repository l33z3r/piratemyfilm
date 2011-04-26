class Admin::HomeController < Admin::AdminController

  def index
   
  end

  private

  def set_selected_tab
    @selected_tab_name = "admin_stats"
  end
  
end
