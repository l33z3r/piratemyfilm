module PostLib
  def self.do_post title, body
    a = WWW::Mechanize.new
    
    a.get("http://www.maxkeiser.com/wp-admin/") do |login_page|
      success_page = login_page.form_with(:action => "http://maxkeiser.com/wp-login.php") do |f|
        f.log = MAX_WP_LOGIN_NAME
        f.pwd = MAX_WP_LOGIN_PW
      end.click_button
    end

    #send blog to mkc
    a.get('http://www.maxkeiser.com/?json=get_nonce&controller=posts&method=create_post') do |page|
      @page = page
    end

    @json_response = ActiveSupport::JSON.decode(@page.body)

    @nonce = @json_response["nonce"]

    a.get("http://www.maxkeiser.com/?json=create_post&nonce=#{@nonce}&status=publish&title=#{title}&content=#{body}") do |page|
      @page = page
    end

    return @page
  end
end
