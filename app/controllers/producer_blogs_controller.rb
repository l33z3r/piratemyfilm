class ProducerBlogsController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show]
  skip_before_filter :check_permissions, :only => [:index, :show]
  
  def index
    @blogs = Blog.find_all_by_is_homepage_blog(false, :order=>"created_at DESC")
  end

  def new
    if params[:project_id]
      @project = Project.find(params[:project_id])
      unless @u.id == @project.owner_id
        flash[:notice] = "you don't have access to this project"
        redirect_to :action => :index
      end
    end
    @blog = Blog.new
  end

  def create
    begin
      @blog = Blog.new(params[:blog])
      @blog.profile_id = @p.id
      @blog.save!
      flash[:notice] = 'New blog post created.'
      if @blog.project_id == nil
        redirect_to :action => "index"
      else
        redirect_to :controller => :projects, :action => :show, :id => @blog.project_id
      end
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Blog Post"
      flash[:negative] = "Sorry, there was a problem creating your blog post"
      render :action=>'new'
    end
  end

  def show
    @blog = Blog.find(params[:id])
  end

  def edit
    @blog = Blog.find(params[:id])
    unless @blog.profile_id == @p.id
      flash[:notice] = 'You do not have permission to edit this blog'
      redirect_to :action => "index"
    end
  end

  def update
    begin
      @blog = Blog.find(params[:id])
      unless @blog.profile_id == @p.id
        flash[:notice] = 'You do not have permission to edit this blog'
        redirect_to :action => "index"
      end
      @blog.update_attributes(params[:blog])
      @blog.save!
      flash[:notice] = 'Blog post updated.'
      redirect_to :action => "index"
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error updating Blog Post"
      flash[:negative] = "Sorry, there was a problem updating your blog post"
      render :action=>'edit'
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    unless @blog.profile_id == @p.id
      flash[:notice] = 'You do not have permission to edit this blog'
      redirect_to :action => "index"
    end
    @blog.destroy
    flash[:notice] = 'Blog post deleted.'
    redirect_to :action => "index"
  end

end
