class Admin::AdminBlogsController < Admin::AdminController
      
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
      @blog.profile_id = nil
      @blog.save!

      if params[:publish_to_mkc]
        #send blog to wordpress
        @html_content = render_to_string(
          :partial => "/blogs/templates/admin_blog_crosspost",
          :locals => {:blog => @blog})
        
        @post_url = PostLib.do_post @html_content
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
