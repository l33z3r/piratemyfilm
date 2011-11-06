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

  def project_completion project
    distance_of_time_in_words Time.now, project.completion_date unless !project.completion_date
  end

  def follow_project_button project
    content_tag :div, :class => "button left" do
      if @u and @u.following? project
        link_to "Unfollow", unfollow_project_project_followings_path(project), :method => :delete
      else
        link_to "Follow", project_project_followings_path(project), :method => "post"
      end
    end
  end
  
  def follow_project_button_small project
    if @u and @u.following? project
      content_tag :div, :class => "button_small left" do
        link_to "Unfollow", unfollow_project_project_followings_path(project), :method => :delete
      end
    else
      content_tag :div, :class => "button_small left" do
        link_to "Follow", project_project_followings_path(project), :method => "post"
      end
    end
  end
  
  def follow_admin_blogs_button_small
    if @u and @u.following_admin_blogs
      content_tag :div, :class => "following_text left" do
        "Following"
      end
    else
      content_tag :div, :class => "button_small left" do
        link_to "Follow", {:controller => "blogs", :action => "follow_admin_blogs"}, :method => "post"
      end
    end
  end
  
  def follow_mkc_blogs_button_small
    if @u and @u.following_mkc_blogs
      content_tag :div, :class => "following_text left" do
        "Following"
      end
    else
      content_tag :div, :class => "button_small left" do
        link_to "Follow", {:controller => "blogs", :action => "follow_mkc_blogs"}, :method => "post"
      end
    end
  end

  def small_view_edit_link project
    if @u && (project.owner == @u || @u.is_admin)
      link_to "(Edit Project)", edit_project_path(project)
    end
  end

  def subscription_info project
    @info = "You must log in to reserve shares for this project."

    if @u and !project.in_payment? and !project.finished_payment_collection
      @amount = project.user_subscription_amount @u
      @outstanding_amount = project.user_subscription_amount_outstanding @u
      @total_amount = @amount + @outstanding_amount

      if @total_amount > 0
        @outstanding_string = ""

        if @outstanding_amount > 0
          @outstanding_string = "<i>(#{@outstanding_amount} on
            <a class='tooltip_arrow'
               title='standby shares become valid when new or existing shares become available'>
              standby</a>)</i>"
        end

        @info = "You have #{@total_amount} shares #{@outstanding_string} reserved for this project."
      else 
        @info = "You do not have any shares in this project."
      end

      return @info
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
    return u.id == Profile.find(PMF_FUND_ACCOUNT_ID).user.id
  end

  def project_icon project, size
    content_tag(:div, :class => "project_image_container") do
      image_tag(project_icon_path(project, size)) +
      
        #include the %funded var as a float over the image
      content_tag(:div, :class => "percent_funded_float") do
        project.percent_funded_with_pmf_fund_non_outstanding.to_s + "&#37 funded"
      end
    end
  end

  def project_icon_path project, size
    if project.icon.nil?
      @img_path = "/images/generic-project-icon.png"
    else
      @img_path = url_for_image_column(project, "icon", size)
      if !@img_path
        @img_path = "/images/generic-project-icon.png"
      end
    end
    
    @img_path
  end

  def watch_project_url project
    if project.main_video
      url_for :controller => "projects", :action => "player", :id => project
    elsif project.watch_url
      project.watch_url
    end
  end

  #helpers to display project talent
  def producers_for project
    if !project.producer_project_talents.empty?
      content = wrap_talents project.producer_project_talents
      return "#{content} #{h(project.producer_name)}"
    else
      return h(project.producer_name)
    end
  end

  def directors_for project
    if !project.director_project_talents.empty?
      content = wrap_talents project.director_project_talents
      return "#{content} #{h(project.director)}"
    else
      return h(project.director)
    end
  end

  def exec_producers_for project
    if !project.exec_producer_project_talents.empty?
      content = wrap_talents project.exec_producer_project_talents
      return "#{content} #{h(project.exec_producer)}"
    else
      return h(project.exec_producer)
    end
  end
  
  def writers_for project
    if !project.writer_project_talents.empty?
      content = wrap_talents project.writer_project_talents
      return "#{content} #{h(project.writer)}"
    else
      return h(project.writer)
    end
  end

  def editors_for project
    if !project.editor_project_talents.empty?
      content = wrap_talents project.editor_project_talents
      return "#{content} #{h(project.editor)}"
    else
      return h(project.editor)
    end
  end

  def directors_photography_for project
    if !project.director_photography_project_talents.empty?
      content = wrap_talents project.director_photography_project_talents
      return "#{content} #{h(project.director_photography)}"
    else
      return h(project.director_photography)
    end
  end
  
  def wrap_talents project_talents
    content = ""
      
    project_talents.each do |p_ut|
      content += "<div class='linked_talent'>"
      content += "<div class='talent_icon'>#{icon(p_ut.user_talent.user.profile, :small)}</div>"
      content += "<div class='talent_name'>#{link_to h(p_ut.user_talent.user.login), profile_path(p_ut.user_talent.user.profile)}</div></div>"
    end
      
    content
  end
  
  def clear_html 
    return "<div class='pmf_clear'>&nbsp;</div>"
  end

  def blog_icon_path blog, size
    if blog.is_mkc_blog
      return "/images/mkc_avatar.png"
    elsif blog.is_admin_blog
      return "/images/pmf_fund_avatar_40.png"
    elsif blog.project
      return project_icon_path(blog.project, size)
      elselse
      return avatar_url_for(blog.profile)
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

  def blog_body blog
    #replace the mentions
    @blog_body = blog.body.gsub( /@\w+/) do |mention|
      @user_login = mention[1..mention.length-1]
      link_to mention, "/#{@user_login}"
    end
    
    #hotlink the urls
    @blog_body = blog.body.gsub( /http:\/\/bit.ly\/\w+/) do |url|
      link_to url, url, :target => "_blank"
    end
    
    @blog_body
  end
  
  def blog_template_name blog
    @template_name = nil
    
    if blog.is_mkc_blog
      @template_name = "mkc_blog"
    elsif blog.is_admin_blog
      @template_name = "admin_blog"
    else
      @template_name = "buzz"
    end
    
    @template_name
  end
  
    #  def blog_body(blog, truncate_blog_body, show_more_link=true)
    #    if defined?(truncate_blog_body) && truncate_blog_body
    #      @blog_body_content = blog.body
    #      @truncate_length = 140
    #
    #      @body = awesome_truncate(@blog_body_content, @truncate_length)
    #    else
    #      @body = blog_body_content blog
    #    end
    #    
    #    if show_more_link
    #      #show the 'more' link unless instructed otherwise
    #      @body += link_to(" (more)", url_for(:controller => "blogs", :action => "show", :id => blog.id, :only_path => false), :class => "more_link")
    #    end
    #    
    #    return @body
    #  end

    def up_down_arrow value
      return " - " if value == 0
      image_tag(value > 0 ? "green_arrow_up.png" : "red_arrow_down.png")
    end
  
    def funding_change_display value
      return "#{up_down_arrow(value)}  #{value.abs}&#37"
    end
  
  
    def avatar(person, avatar_options={}, html_options={})
      #never want to have an alt param
      if !html_options[:alt]
        html_options.merge!(:alt => "")
      end
        
      avatar_tag(person, avatar_options, html_options)
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