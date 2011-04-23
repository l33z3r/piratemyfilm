class BlogCommentsController < ApplicationController
  before_filter :login_required
  skip_before_filter :check_permissions
  
  def create
    @blog_comment = BlogComment.new(params[:blog_comment])
    @blog = @blog_comment.blog

    #verify captcha
    if need_captcha
      if !check_captcha true
        redirect_to blog_url(@blog) and return
      end
    end

    if @blog_comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to blog_url(@blog)
    else
      flash[:error] = "Error creating comment! Make sure field is not empty."
      redirect_to blog_url(@blog)
    end
  end
  
  def destroy
    @blog_comment = BlogComment.find(params[:id])
    @blog = @blog_comment.blog
    @blog_comment.destroy

    redirect_to blog_url(@blog)
  end
end
