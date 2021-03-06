module PostLib
  def self.do_post html_content
    a = Mechanize.new
    
    @wordpress_site_url = WP_SITE_URL
    
    a.get("#{@wordpress_site_url}/wp-admin/") do |login_page|
      success_page = login_page.form_with(:action => "#{@wordpress_site_url}/wp-login.php") do |f|
        f.log = WP_SITE_LOGIN_NAME
        f.pwd = WP_SITE_LOGIN_PW
      end.click_button
    end

    #send blog to mkc
    a.get("#{@wordpress_site_url}?json=get_nonce&controller=posts&method=create_post") do |page|
      @page = page
    end

    @json_response = ActiveSupport::JSON.decode(@page.body)

    @nonce = @json_response["nonce"]

    @title = CGI::escape("Latest Buzz from PirateMyfilm.com")
    
    @body = "#{html_content}"
    
    #get rid of new lines, as json api has a problem with them 
    @body = @body.gsub(/\r/," ")
    @body = @body.gsub(/\n/," ")
    
    @body = CGI::escape(@body)
    
    @is_draft = false
    
    @publish_status = @is_draft ? "draft" : "publish"
    
    @params = "json=create_post&nonce=#{@nonce}&status=#{@publish_status}&title=#{@title}&content=#{@body}"
    @post_url = "#{@wordpress_site_url}?#{@params}"
    
    a.get(@post_url) do |page|
      @page = page
    end

    return @post_url
  end
end
