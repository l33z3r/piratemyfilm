module BlogsHelper
  
  def blogs_li blogs
    html = ''
    blogs.each do |b|
      html += "<li>#{link_to b.title, profile_blog_path(@profile, b)} written #{time_ago_in_words b.created_at} ago</li>"
    end
    html
  end
  
  def blog_body_content blog
    youtube_videos = blog.body.scan(/\[youtube:+.+\]/)
    b = blog.body.dup.gsub(/\[youtube:+.+\]/, '')
    out = safe_textilize(b)
    unless youtube_videos.empty?
    out << <<-EOB
    <strong>#{pluralize youtube_videos.size, 'video'}:</strong><br/>
EOB
    youtube_videos.each do |o|
    out << tb_video_link(o.gsub!(/\[youtube\:|\]/, ''))
      end
    end

    out
  end

  def show_blog_edit_buttons blog
    @p && (@p.id == blog.profile_id || @u.is_admin) && !blog.is_admin_blog && !blog.is_mkc_blog
  end
end
