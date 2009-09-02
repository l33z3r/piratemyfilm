class Admin::HomeController < Admin::AdminController

  def index
    @user_count = User.find(:all).size
  end
  
end
