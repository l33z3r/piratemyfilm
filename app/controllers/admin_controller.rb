class AdminController < ApplicationController
  def index
    @projects = Project.find(:all, :order=>"created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 8
  end

end
