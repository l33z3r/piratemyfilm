class Admin::BlogsController < Admin::AdminController
  
  def index
    @blogs = Blog.find_all_by_is_homepage_blog(true)
  end



  def create
    @blog = @p.blogs.build params[:blog]

    respond_to do |wants|
      if @blog.save
        wants.html do
          flash[:notice] = 'New blog post created.'
          redirect_to profile_blogs_path(@p)
        end
      else
        wants.html do
          flash.now[:error] = 'Failed to create a new blog post.'
          render :action => :new
        end
      end
    end
  end

  def show
    render
  end

  def edit
    render
  end

  def update
    respond_to do |wants|
      if @blog.update_attributes(params[:blog])
        wants.html do
          flash[:notice]='Blog post updated.'
          redirect_to profile_blogs_path(@p)
        end
      else
        wants.html do
          flash.now[:error]='Failed to update the blog post.'
          render :action => :edit
        end
      end
    end
  end

  def destroy
    @blog.destroy
    respond_to do |wants|
      wants.html do
        flash[:notice]='Blog post deleted.'
        redirect_to profile_blogs_path(@p)
      end
    end
  end

end
