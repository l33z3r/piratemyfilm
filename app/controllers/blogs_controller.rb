class BlogsController < ApplicationController
  skip_before_filter :login_required, :only=> [:show, :index, :admin, :mkc, :producer]
  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]
  before_filter :check_project_owner, :only => [:new, :create, :edit, :update, :destroy]

  def index
    #global live stream

    @blogs = Blog.all_blogs
    @pmf_fund_comments = ProjectComment.latest

    @items = @blogs + @pmf_fund_comments

    @items.sort! do |a,b|
      b.created_at <=> a.created_at
    end

    @items = @items.paginate :page => (params[:page] || 1), :per_page=> 15

    if params[:format] == "rss"
      render :action => "all_blogs_rss", :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
    end
  end

  def producer
    @user_id = params[:user_id]

    if !@user_id
      @blogs = Blog.producer_blogs.paginate :page => (params[:page] || 1), :per_page=> 15
    else
      begin
        @user = User.find(@user_id)
        @blogs = Blog.user_blogs(@user).paginate :page => (params[:page] || 1), :per_page=> 15
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "User not found!"
        redirect_to :action => "index"
      end
    end
  end

  def admin
    @blogs = Blog.admin_blogs.paginate :page => (params[:page] || 1), :per_page=> 15
  end

  def mkc
    @blogs = Blog.mkc_blogs
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

        if @project && @project.is_deleted
          flash[:error] = "This Project has been deleted!"
          redirect_to :controller => "home"
        end
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "This blog entry does not exist"
        redirect_to :controller => "home"
      end
    end
  end

  def check_project_owner
    #is this an admin blog and are we admin
    if @blog && @blog.is_admin_blog && @u.is_admin
      return
    end

    #is this an mkc blog, not allowed to edit
    if @blog && @blog.is_mkc_blog
      permission_denied
    end

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
    flash[:error] = "You do not have permission to do this!"
    redirect_to :controller => "home"
  end

  def allow_to
    super :all, :only => [:show, :index, :admin, :mkc, :producer]
    super :user, :all => true
  end
  
end
