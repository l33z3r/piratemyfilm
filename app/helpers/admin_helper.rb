module AdminHelper
  def blog_header(blog, link_blog_header, truncate_blog_header)
    if defined?(link_blog_header) && link_blog_header
      if defined?(truncate_blog_header) && truncate_blog_header
        @blog_header_content = blog.title
        @truncate_length = 20

        @blog_header_title = awesome_truncate(@blog_header_content, @truncate_length)
      else
        @blog_header_title = blog.title
      end

      link_to sanitize(@blog_header_title.capitalize), :controller => "admin/admin_blogs", :action => "show", :id => blog.id
    else
      sanitize(blog.title.capitalize)
    end
  end

  def blog_body(blog, truncate_blog_body)
    if defined?(truncate_blog_body) && truncate_blog_body
      @blog_body_content = blog.body
      @truncate_length = 50

      @body = awesome_truncate(@blog_body_content, @truncate_length)

      if @blog_body_content.length > @truncate_length
        @body += link_to "(More)", {:controller => "admin/admin_blogs", :action => "show", :id => blog.id}, :class => "more_link"
      end
    else
      @body = blog_body_content blog
    end

    return @body
  end
end
