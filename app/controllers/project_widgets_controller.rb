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
    @frame_height = 165 * @num_projects
    @frame_height += 140
    @generated_code = "<iframe width='300' height='#{@frame_height}' frameborder='0' scrolling='no' src='#{@widget_url}'></iframe>"
  end

  def render_widget
    if !@num_projects or !@num_projects.is_a?(Integer) or !@filter_param or !@filter_param.is_a?(Integer)
      render :inline => "Bad Parameters" and return
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
    
    if @filter_param
      @filter_param = @filter_param.to_i
    end
  end

  def allow_to
    super :all, :all => true
  end

end
