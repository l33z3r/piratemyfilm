class BlogsController < ApplicationController
  skip_filter :login_required, :only => [:show, :homepage, :producer]
  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]
  before_filter :check_project_owner, :only => [:new, :create, :edit, :update, :destroy]
  
  def producer
    @blogs = Blog.for_homepage.paginate :page => (params[:page] || 1), :per_page=> 5
  end
  
  def homepage

    @hide_intro_blog = true
    
    @blogs = Blog.find_all_by_is_homepage_blog(true, :order => "created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 5

    if params[:format] == "rss"
      render :action => "homepage_rss", :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
    end
  end

  def new
    @blog = Blog.new
  end
  
  def create
    begin
      @blog = Blog.new(params[:blog])
      @blog.profile_id = @p.id
      @blog.save!

      flash[:notice] = 'New blog post created.'
      redirect_to :controller => "blogs", :action => "show", :id => @blog.id
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Sorry, there was a problem creating your blog post"
      render :action => 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    begin
      @blog.update_attributes(params[:blog])
      @blog.save!

      flash[:notice] = 'Blog post updated.'
      redirect_to :controller => "blogs", :action => "show", :id => @blog.id
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Sorry, there was a problem updating your blog post"
      render :action => 'edit'
    end
  end
  
  def show
    @hide_intro_blog = true

    @title = @blog.title

    @blog_comment = BlogComment.new
  end

  def destroy
    @blog.destroy
    flash[:notice] = 'Blog post deleted.'
    redirect_to :controller => "home"
  end

  protected
  
  def load_blog
    if params[:id]
      begin
        @blog = Blog.find(params[:id])
        @project = @blog.project
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "This blog entry does not exist"
        redirect_to :controller => "home"
      end
    end
  end

  def check_project_owner
    begin
      #try load project from params
      @project_id = params[:project_id]
      @project_id ||= params[:blog][:project_id] unless !params[:blog]

      @project ||= Project.find(@project_id) 

      if @u.id != @project.owner_id && !@u.is_admin
        permission_denied
      end
    rescue ActiveRecord::RecordNotFound
      permission_denied
    end
  end

  def permission_denied
    flash[:error] = "You do not have permissions on this project!"
    redirect_to :controller => "home"
  end

  def allow_to
    super :user, :all => true
    super :non_user, :only => [:show, :homepage, :producer]
  end
  
end
