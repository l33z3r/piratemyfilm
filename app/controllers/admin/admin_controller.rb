class Admin::AdminController < ApplicationController

  layout "admin"

  before_filter :load_vars, :set_selected_tab

  private

  def load_vars
    @num_pending_projects = Project.find(:all, :conditions => "symbol is null and is_deleted = 0").size
    @num_deleted_projects = Project.find(:all, :conditions => "is_deleted").size
    @user_count = User.find(:all).size
  end

  def allow_to
    super :admin, :all => true
  end

end
