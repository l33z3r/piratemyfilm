class Admin::AdminBlogsController < Admin::AdminController

  #inclusion of some view helpers so we can render some 
  #linkback html for the cross posting to mkc
#  include ActionView::Helpers::TagHelper
#  include ActionView::Helpers::AssetTagHelper
#  include ProfilesHelper
#  
#  include ActionView::Helpers::UrlHelper
#  include ActionController::UrlWriter
#  
        
  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.find_all_by_is_admin_blog(true, :order=>"created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 15
  end

  def new
    @blog = Blog.new
  end

  def create
    begin
      @blog = Blog.new(params[:blog])
      @blog.is_admin_blog = true
      @blog.profile_id = PMF_FUND_ACCOUNT_ID
      @blog.save!

      if params[:publish_to_mkc]
        @link_back_html = "</br></br>Posted by <div class='icon'>#{@template.icon(@blog.profile, :small)}</div>"
        @link_back_html += "<div class='name'>#{@template.link_to(@blog.profile.user.f.titleize, @template.profile_url(@blog.profile))} - #{@template.link_to("Follow this member!", @template.profile_url(@blog.profile))}</div>" 
        @link_back_html += "</br></br>on <a href='www.piratemyfilm.com'>www.piratemyfilm.com</a>"
        
        #send blog to mkc
        @post_url = PostLib.do_post @blog, @link_back_html
        logger.info "Sent blog to mkc: #{@post_url}"
      end

      flash[:notice] = 'New blog post created.'
      redirect_to :action => "show", :id => @blog.id
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Blog Post"
      flash[:error] = "Sorry, there was a problem creating your blog post"
      render :action=>'new'
    end
  end

  def show
    @blog = Blog.find(params[:id])
    @blog_comment = BlogComment.new
  end

  def edit
    @blog = Blog.find(params[:id])
  end

  def update
    begin
      @blog = Blog.find(params[:id])
      @blog.update_attributes(params[:blog])
      @blog.save!
      flash[:notice] = 'Blog post updated.'
      redirect_to :action => "show", :id => @blog.id
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error updating Blog Post"
      flash[:error] = "Sorry, there was a problem updating your blog post"
      render :action=>'edit'
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy
    flash[:notice] = 'Blog post deleted.'
    redirect_to :action => "index"
  end

  protected

  def load_blog
    if params[:id]
      begin
        @blog = Blog.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "This blog entry does not exist"
        redirect_to :action => "index"
      end
    end
  end

  def redirect_to_admin_home
    redirect_to :controller => "admin/home"
  end

  def set_selected_tab
    @selected_tab_name = "blogs"
  end

end
