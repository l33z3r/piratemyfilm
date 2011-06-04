class BlogsController < ApplicationController
  skip_before_filter :login_required, :only=> [:show, :index, :all_member_blogs, :admin, :mkc]

  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]
  before_filter :check_blog_permissions, :only => [:new, :create, :edit, :update, :destroy]

  #this is the global live project feed
  def index
    @blogs = Blog.all_project_blogs

    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15
    
    if params[:format] == "rss"
      render :action => "all_blogs_rss", :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
    end
  end
  
  #this is the users personal live project feed
  def my_project_blogs
    #users live project follow stream
    @blogs = Blog.all_for_user_followings @u

    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15
    
    @selected_user_subnav_link = "my_project_blogs"
  end

  #this is the global live member feed
  def all_member_blogs
    @blogs = Blog.all_member_blogs
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15
  end
  
  #this is the users personal live member feed
  def my_member_blogs
    @blogs = Blog.my_followings @u
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15

    @selected_user_subnav_link = "my_member_blogs"
  end

  def admin
    @blogs = Blog.admin_blogs.paginate :page => (params[:page] || 1), :per_page=> 15
  end

  def mkc
    @blogs = Blog.mkc_blogs.paginate :page => (params[:page] || 1), :per_page=> 15
  end
  
  def create
    begin
      @blog = Blog.new(params[:blog])
      
      if @blog.body.blank?
        flash[:error] = "Your update has no content..."
        redirect_to :back and return
      end
      
      if params[:project_id] and params[:project_id] != "-1"
        if !params[:project_user_talent_id].blank?
          @put = ProjectUserTalent.find(params[:project_user_talent_id])
          @blog.project_user_talent_id = @put.id
        end
        
        @project = Project.find(params[:project_id])
        @blog.project_id = @project.id
      end

      @blog.profile_id = @u.profile.id
      @blog.save!
      
      #do mkc cross post
      if params[:publish_to_mkc] and @u.mkc_post_ability
        
        #send blog to wordpress
        @html_content = render_to_string(
          :partial => "/blogs/templates/member_blog_crosspost",
          :locals => {:blog => @blog})
        
        @post_url = PostLib.do_post @html_content
        
        logger.info "Sent blog to wordpress site via url: #{@post_url}"
      end

      flash[:notice] = 'New blog post created.'
      redirect_to :controller => "blogs", :action => "show", :id => @blog.id
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Sorry, there was a problem creating your blog post"
      redirect_to :back
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
  
  def follow_admin_blogs
    @u.following_admin_blogs = true
    @u.save
    
    flash[:notice] = "You are now following the PMF Blog!"
    redirect_to :action => "admin"
  end
  
  def follow_mkc_blogs
    @u.following_mkc_blogs = true
    @u.save
    
    flash[:notice] = "You are now following the MKC Blog!"
    redirect_to :action => "mkc"
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

  def check_blog_permissions
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

      if !allowed_to_blog?(@u, @project) && !@u.is_admin
        permission_denied
      end
    rescue ActiveRecord::RecordNotFound
      #ignore this, as there may not be a project linked to this blog
    end

  end
  
  def allowed_to_blog?(u, project)
    #can blog if owner
    return true if u.id == project.owner_id
    
    #can blog if talent of project
    project.project_user_talents.each do |put|
      return true if u.id == put.user_talent.user.id
    end
    
    #can blog if own shares in project
    project.subscribers.each do |subscriber|
      return true if u.id == subscriber.id
    end
    
    return false
  end

  def permission_denied
    flash[:error] = "You do not have permission to do this!"
    redirect_to :controller => "home"
  end

  def allow_to
    super :all, :only => [:show, :index, :all_member_blogs, :admin, :mkc]
    super :user, :all => true
  end
  
end
