class Admin::HomepageBlogController < Admin::AdminController
  
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
      @blog.save!
      flash[:notice] = 'New blog post created.'
      redirect_to :action => "index"
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
  end

  def update
    begin
      @blog = Blog.find(params[:id])
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
    @blog.destroy
    flash[:notice] = 'Blog post deleted.'
    redirect_to :action => "index"
  end

end
