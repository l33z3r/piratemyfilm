class ProjectWidgetsController < ApplicationController

  skip_before_filter :login_required
  before_filter :set_params

  def index
  end

  def generate_markup
    if !@num_projects or !@num_projects.is_a?(Integer) or !@filter_param
      redirect_to :action => "index" and return
    end
    
    @widget_params = "?num_projects=#{@num_projects}&filter_param=#{@filter_param}"
    @widget_url = url_for(:action => "render_widget", :only_path => false)
    @widget_url += @widget_params
    @frame_height = 122 * @num_projects
    @frame_height += 135
    @generated_code = "<iframe width='300' height='#{@frame_height}' frameborder='0' scrolling='no' src='#{@widget_url}'></iframe>"
  end

  def render_widget
    if !@num_projects or !@num_projects.is_a?(Integer) or !@filter_param
      render :inline => "Bad Parameters" and return
    end

    if @filter_param = params[:filter_param]
      @filter = Project.get_filter_sql @filter_param
      @order = Project.get_order_sql @filter_param

      @projects = Project.find_all_public(:conditions => @filter, :order=> @order, :limit => @num_projects).paginate :page => (params[:page] || 1), :per_page=> 15
    else
      @projects = Project.find_all_public(:order => "percent_funded DESC, rated_at DESC, created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 15
    end
    
    render :action => "render_widget", :layout => false
  end

  private

  def set_params
    @num_projects = params[:num_projects]

    if @num_projects
      @num_projects = @num_projects.to_i
    end

    @filter_param = params[:filter_param]
  end

  def allow_to
    super :all, :all => true
  end

end
