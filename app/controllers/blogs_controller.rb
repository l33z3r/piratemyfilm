class BlogsController < ApplicationController
  skip_before_filter :login_required, :only=> [:show, :index, :members, :admin, :mkc, :producer]

  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]
  before_filter :check_project_owner, :only => [:new, :create, :edit, :update, :destroy]

  #this is the global live project feed
  def index
    @blogs = Blog.all_project_blogs
    @pmf_fund_comments = ProjectComment.latest
    @admin_project_ratings = AdminProjectRating.latest

    #we don't show the subscription history anymore
    #@pmf_project_subscriptions = PmfFundSubscriptionHistory.latest

    @new_projects = Project.find_all_public(:order => "created_at DESC")

    @items = @blogs + @pmf_fund_comments + @admin_project_ratings + @new_projects# + @pmf_project_subscriptions

    @items.sort! do |a,b|
      b.created_at <=> a.created_at
    end

    @items = @items.paginate :page => (params[:page] || 1), :per_page=> 15

    if params[:format] == "rss"
      render :action => "all_blogs_rss", :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
    end
  end
  
  #this is the users personal live project feed
  def my_project_blogs
    #users live project follow stream
    @blogs = Blog.all_for_user_followings @u
    @pmf_fund_comments = ProjectComment.latest_for_user_followings @u
    @admin_project_ratings = AdminProjectRating.latest_for_user_followings @u
    @pmf_project_subscriptions = PmfFundSubscriptionHistory.latest_for_user_followings @u

    @items = @blogs + @pmf_fund_comments + @admin_project_ratings + @pmf_project_subscriptions

    @items.sort! do |a,b|
      b.created_at <=> a.created_at
    end

    @items = @items.paginate :page => (params[:page] || 1), :per_page=> 15
    
    @selected_user_subnav_link = "my_project_blogs"
  end

  #this is the global live member feed
  def all_member_blogs
    @blogs = Blog.all_member_blogs
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15

    @blog = Blog.new
  end
  
  #this is the users personal live member feed
  def my_member_blogs
    @blogs = Blog.my_followings @u
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15

    @blog = Blog.new
    
    @selected_user_subnav_link = "my_member_blogs"
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
      
      if params[:project_id] and params[:project_id] != "-1"
        @project = Project.find(params[:project_id])
        @blog.project_id = @project.id
      end

      @blog.save!

      flash[:notice] = 'New blog post created.'

      if @blog.is_member_blog
        redirect_to :action => "my_member_blogs" and return
      end
      
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
      #ignore this, as there may not be a project linked to this blog
    end

  end

  def permission_denied
    flash[:error] = "You do not have permission to do this!"
    redirect_to :controller => "home"
  end

  def allow_to
    super :all, :only => [:show, :index, :members, :admin, :mkc, :producer]
    super :user, :all => true
  end
  
end
