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

  #  def display_standard_flashes(message = 'There were some problems with your submission:')
  #    if flash[:notice]
  #      flash_to_display, level = flash[:notice], 'notice'
  #    elsif flash[:warning]
  #      flash_to_display, level = flash[:warning], 'warning'
  #    elsif flash[:error]
  #      level = 'error'
  #      if flash[:error].instance_of?( ActiveRecord::Errors) || flash[:error].is_a?( Hash)
  #        flash_to_display = message
  #        flash_to_display << activerecord_error_list(flash[:error])
  #      else
  #        flash_to_display = flash[:error]
  #      end
  #    else
  #      return
  #    end
  #    content_tag 'div', flash_to_display, :class => "flash#{level}"
  #  end

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
    project.green_light ? "Green Lit Project!" : ""
  end

  def project_icon project, size
    image_tag project_icon_path(project, size)
  end

  def project_icon_path project, size
    if project.icon.nil?
      "/images/generic-project-icon.png"
    else
      url_for_file_column(project, "icon", size)
    end
  end

  def blog_icon blog, size
    image_tag blog_icon_path(blog, size)
  end

  def blog_icon_path blog, size
    if blog.is_producer_blog
      return project_icon_path(blog.project, size)
    elsif blog.is_mkc_blog
      return "/images/mkc_avatar.png"
    elsif blog.is_admin_blog
      return "/images/pmf_fund_avatar.png"
    end
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

end
