class Admin::HomepageBlogController < Admin::AdminController

  before_filter :load_blog, :only => [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.find_all_by_is_homepage_blog(true, :order=>"created_at DESC")
  end

  def new
    @blog = Blog.new
  end

  def create
    begin
      @blog = Blog.new(params[:blog])
      @blog.is_homepage_blog = true
      @blog.profile_id = @p.id
      @blog.save!
      flash[:notice] = 'New blog post created.'
      redirect_to :controller => "/home", :action => "index"
    rescue ActiveRecord::RecordInvalid
      logger.debug "Error creating Blog Post"
      flash[:negative] = "Sorry, there was a problem creating your blog post"
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
      flash[:negative] = "Sorry, there was a problem updating your blog post"
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

end
