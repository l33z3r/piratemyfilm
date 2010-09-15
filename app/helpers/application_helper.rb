module ApplicationHelper
  require 'digest/sha1'
  require 'net/http'
  require 'uri'

  def less_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    form_for name, *args, &block
  end
  
  def less_remote_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    remote_form_for name, *args, &block
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end

  def inline_tb_link link_text, inlineId, html = {}, tb = {}
    html_opts = {
      :title => '',
      :class => 'thickbox'
    }.merge!(html)
    tb_opts = {
      :height => 300,
      :width => 400,
      :inlineId => inlineId
    }.merge!(tb)
    
    path = '#TB_inline'.add_param(tb_opts)
    link_to(link_text, path, html_opts)
  end
  
  def tb_video_link youtube_unique_path
    return if youtube_unique_path.blank?
    youtube_unique_id = youtube_unique_path.split(/\/|\?v\=/).last.split(/\&/).first
    p youtube_unique_id
    client = YouTubeG::Client.new
    video = client.video_by YOUTUBE_BASE_URL+youtube_unique_id rescue return "(video not found)"
    id = Digest::SHA1.hexdigest("--#{Time.now}--#{video.title}--")
    inline_tb_link(video.title, h(id), {}, {:height => 355, :width => 430}) + %(<div id="#{h id}" style="display:none;">#{video.embed_html}</div>)
  end
  
  def me
    @p == @profile
  end
  
  def is_admin? user = nil
    user && user.is_admin?
  end
  
  def if_admin
    yield if is_admin? @u
  end
  
  def display_error_on(object, field_name)
    if object.errors.on(field_name)
      content_tag(:span, show_field_errors(object, field_name), :class=>"error")
    end
  end
  
  def show_field_errors(object, field_name)
    errors = object.errors.on(field_name)
    errors.is_a?(Array) ? errors.first : errors# errors.to_sentence : errors
  end

  def follow_project_button project
    content_tag :div, :class => "button left" do
      if @u and @u.following? project
        link_to "Un-Follow", unfollow_project_project_followings_path(project), :method => :delete
      else
        link_to "Follow", project_project_followings_path(project), :method => "post"
      end
    end
  end
  
  def follow_project_button_small project
    if @u and @u.following? project
      content_tag :div, :class => "following_text left" do
        "Following..."
      end
    else
      content_tag :div, :class => "button_small left" do
        link_to "Follow", project_project_followings_path(project), :method => "post"
      end
    end
  end

  def subscription_info project
    if @u
      @amount = project.user_subscription_amount @u

      if @amount > 0
        @outstanding_amount = project.user_subscription_amount_outstanding @u

        @outstanding_string = ""

        if @outstanding_amount > 0
          @outstanding_string = "<i>(#{@outstanding_amount} on
            <a class='tooltip_arrow'
               title='standby shares become valid when new orexisting shares become available'>
              standby</a>)</i>"
        end

        "You have #{@amount} shares #{@outstanding_string} reserved for this project."
      end
    end
  end
  
  # type can be error or positive or blank
  def show_flash(messages=nil,type='')
    output = "<p id=\"flash_#{type}\">"

    unless messages.nil?
      if messages.is_a? String
        output << %(<p id="flash_#{type}" class="feedback #{type}">#{messages}</p>)
      else
        messages.each { |message| output << %(<p id="flash_#{type}" class="feedback #{type}">#{message.to_s}</p>) }
      end
    end
    
    output << "</p>"
    output
  end
  
  def show_default_flash
    [:notice,:positive,:error].inject('') { |output,type| output << show_flash(flash[type],type) }
  end

  def pagination_controls_for(collection, prev_class="prev", next_class="next")
    pagination = will_paginate(collection, :prev_label=>"<< Previous", :next_label=>"Next >>", :prev_class=>prev_class, :next_class=>next_class)
    if pagination
      output = '<div class="pagination">'
      output << pagination
      output << '</div>'
    end
  end

  def total_pages(collection)
    WillPaginate::ViewHelpers.total_pages_for_collection(collection)
  end
  
  def logged_in
    !@u.nil? and !@u.new_record?
  end

  # Awesome truncate
  # First regex truncates to the length, plus the rest of that word, if any.
  # Second regex removes any trailing whitespace or punctuation (except ;).
  # Unlike the regular truncate method, this avoids the problem with cutting
  # in the middle of an entity ex.: truncate("this &amp; that",9)  => "this &am..."
  # though it will not be the exact length.
  def awesome_truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.chars.length
    text.chars.length > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end

  def safe_textilize( s )
    if s && s.respond_to?(:to_s)
      doc = RedCloth.new( s.to_s )
      doc.filter_html = true
      doc.to_html
    end
  end

  def pmf_fund_user? u
    return u.id == PMF_FUND_ACCOUNT_ID
  end

  def project_green_light project
    project.green_light ? "(Green Light)" : ""
  end

  def project_icon project, size
    image_tag project_icon_path(project, size)
  end

  def project_icon_path project, size
    if project.icon.nil?
      "/images/generic-project-icon.png"
    else
      url_for_image_column(project, "icon", size)
    end
  end

  def blog_icon_path blog, size
    if blog.is_producer_blog
      return project_icon_path(blog.project, size)
    elsif blog.is_mkc_blog
      return "/images/mkc_avatar.png"
    elsif blog.is_admin_blog
      return "/images/pmf_fund_avatar_40.png"
    end
  end

  def blog_header(blog, link_blog_header, truncate_blog_header)
    if defined?(link_blog_header) && link_blog_header
      if defined?(truncate_blog_header) && truncate_blog_header
        @blog_header_content = blog.title
        @truncate_length = 20

        @blog_header_title = awesome_truncate(@blog_header_content, @truncate_length)
      else
        @blog_header_title = blog.title
      end

      link_to sanitize(@blog_header_title.capitalize), :controller => "blogs", :action => "show", :id => blog.id
    else
      sanitize(blog.title.capitalize)
    end
  end

  def blog_project_header(blog, truncate_blog_project_title)
    if defined?(truncate_blog_project_title) && truncate_blog_project_title
      @blog_project_title_content = blog.project.title
      @truncate_length = 50

      @blog_header_title = awesome_truncate(@blog_project_title_content, @truncate_length)
    else
      @blog_header_title = blog.project.title
    end

    link_to h(@blog_header_title.capitalize), project_path(blog.project)
  end

  def blog_body(blog, truncate_blog_body)
    if defined?(truncate_blog_body) && truncate_blog_body
      @blog_body_content = blog.body
      @truncate_length = 50

      @body = awesome_truncate(@blog_body_content, @truncate_length)

      if @blog_body_content.length > @truncate_length
        @body += link_to "(More)", {:controller => "blogs", :action => "show", :id => blog.id}, :class => "more_link"
      end
    else
      @body = blog_body_content blog
    end

    return @body
  end

  def blog_template_name blog
    if blog.is_producer_blog
      return "producer_blog"
    elsif blog.is_mkc_blog
      return "mkc_blog"
    elsif blog.is_admin_blog
      return "admin_blog"
    end
  end

  def up_down_arrow value
    return if value == 0
    image_tag(value > 0 ? "green_arrow_up.png" : "red_arrow_down.png")
  end

  #RJS helper methods

  def rjs_update_flashes flash
    if flash[:positive]
      page.replace_html :flash_positive, "<p class=\"feedback positive\">#{flash[:positive]}</p>"
    else
      page.replace_html :flash_positive, ""
    end

    if flash[:notice]
      page.replace_html :flash_notice, "<p class=\"feedback notice\">#{flash[:notice]}</p>"
    else
      page.replace_html :flash_notice, ""
    end

    if flash[:error]
      page.replace_html :flash_error, "<p class=\"feedback error\">#{flash[:error]}</p>"
    else
      page.replace_html :flash_error, ""
    end
  end

  def me_or_login
    if @p == @profile
      "My"
    else
      @profile.user.login + "'s"
    end
  end
end