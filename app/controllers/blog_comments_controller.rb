class BlogCommentsController < ApplicationController
  before_filter :login_required
  skip_before_filter :check_permissions
  
  def create
    @blog_comment = BlogComment.new(params[:blog_comment])
    @blog = @blog_comment.blog

    
    if @blog_comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to blog_url(@blog)
    else
      render blog_url(@blog)
    end
  end
  
  def destroy
    @blog_comment = BlogComment.find(params[:id])
    @blog = @blog_comment.blog
    @blog_comment.destroy

    redirect_to blog_url(@blog)
  end
end