class Admin::AdminController < ApplicationController

  layout "admin"

  before_filter :load_vars, :set_selected_tab

  private

  def load_vars
    @num_pending_projects = Project.find(:all, :conditions => "symbol is null and is_deleted = 0").size
    @num_deleted_projects = Project.find(:all, :conditions => "is_deleted").size
    @num_flagged_projects = Project.all_flagged.size
    @user_count = User.find(:all).size
    @num_buyout_requests = (PmfShareBuyout.all_open | PmfShareBuyout.all_pending).size
  end

  def allow_to
    super :admin, :all => true
  end

end
