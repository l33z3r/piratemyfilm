class AccountsController < ApplicationController
  skip_before_filter :login_required, :except => :logout
  skip_after_filter :store_location
 
  def login
    redirect_back_or_default(home_path) and return if @u
    @user = User.new
    return unless request.post?
    
    #plays double duty login/forgot (due to the ajax nature of the login/forgot form)
    if params[:user][:email] && params[:user][:email].size > 0
      u = Profile.find_by_email(params[:user][:email]).user rescue nil
      flash.now[:error] = "Could not find that email address. Try again." and return if u.nil?

      @pass = u.forgot_password #must be @ variable for function tests
      AccountMailer.deliver_forgot_password(u.profile.email, u.f, u.login, @pass)
      flash.now[:notice] = "A new password has been mailed to you."
    else
      params[:login] ||= params[:user][:login] if params[:user]
      params[:password] ||= params[:user][:password] if params[:user]

      begin
        self.user = User.authenticate(params[:login], params[:password])
        if @u
          remember_me if params[:remember_me] == "1"
          flash[:notice] = "Logged In Successfully"
          
          #go to the users profile page now, rather than the last url
          #redirect_back_or_default profile_url(@u.profile)
          redirect_to :controller => :blogs, :action => "my_member_blogs" and return
        else
          flash.now[:error] = "Uh-oh, login didn't work. Do you have caps locks on? Try it again."
        end
      rescue Exceptions::UserNotActivated
        AccountMailer.deliver_signup_notification User.find_by_login(params[:login])
        redirect_to :action => "activation_required" and return
      end
    end
  end
  
  def logout
    cookies[:auth_token] = {:expires => Time.now-1.day, :value => "" }
    session[:user] = nil
    session[:return_to] = nil
    flash[:notice] = "You have been logged out."
    redirect_to '/'
  end

  def signup
    redirect_back_or_default(home_path) and return if @u
    @user = User.new
    return unless request.post?

    #verify captcha
    return unless check_captcha
    
    u = User.new

    u.login = params[:user][:login]
    u.password = params[:user][:password]
    u.password_confirmation = params[:user][:password_confirmation]
    u.email = params[:user][:email]
    u.less_value_for_text_input = params[:user][:less_value_for_text_input]

    #give user a membership
    Membership.create(:user => u, :membership_type => MembershipType.find_by_name("Basic"))

    if u.save
      #self.user = u
      flash[:notice] = "Thanks for signing up, please check your email to verify your account!"
      AccountMailer.deliver_signup_notification u
      AuthMailer.deliver_registration(:subject=>"new #{SITE_NAME} registration", 
        :body => "username = '#{u.login}', email = '#{u.profile.email}'",
        :recipients=>REGISTRATION_RECIPIENTS)
      redirect_back_or_default('/')
    else
      @user = u
      params[:user][:password] = params[:user][:password_confirmation] = ''
      self.user = u
    end
  end

  def activate
    @user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if @user && !@user.activated?
      @user.activate
      self.user = @user unless logged_in?
      AccountMailer.deliver_signup @user
      flash[:positive] = "Thanks, your account has been activated"
      redirect_back_or_default('/')
    else
      flash[:negative] = "You have already activated your account!"
      redirect_back_or_default('/')
    end
  end

  protected

  def remember_me
    self.user.remember_me
    cookies[:auth_token] = {
      :value => self.user.remember_token ,
      :expires => self.user.remember_token_expires_at
    }
  end
  
  def allow_to
    super :all, :all=>true
  end
  
end








class AuthMailer < ActionMailer::Base
  def registration(options)
    self.generic_mailer(options)
  end
end