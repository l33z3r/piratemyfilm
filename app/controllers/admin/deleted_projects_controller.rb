class Admin::DeletedProjectsController < Admin::AdminController

  def index
    @projects = Project.find(:all, :conditions => "is_deleted", :order=>"created_at").paginate :page => (params[:page] || 1), :per_page=> 8
  end
  
end
