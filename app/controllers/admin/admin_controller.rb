class Admin::AdminController < ApplicationController

  layout "admin"

  before_filter :load_vars

  private

  def allow_to
    super :admin, :all => true
  end

  def load_vars
    @num_pending_projects = Project.find(:all, :conditions => "rated_at is null and is_deleted = 0").size
  end
  
end
