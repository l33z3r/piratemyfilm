class ApplicationController < ActionController::Base

  include ActionView::Helpers::NumberHelper
  
  helper :all
  include ExceptionNotifiable
  filter_parameter_logging "password"
  
  before_filter :allow_to, :check_user, :login_from_cookie, :login_required, :set_profile
  before_filter :check_permissions, :pagination_defaults
  before_filter :load_filter_params, :load_sitewide_vars
  
  after_filter :store_location
  layout 'application'  

  helper_method :print_money, :print_number, :allowed_reserve_shares
  
  def check_featured
    return if Profile.featured_profile[:date] == Date.today
    Profile.featured_profile[:date] = Date.today
    Profile.featured_profile[:profile] = Profile.featured
  end
  
  def pagination_defaults
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @per_page = (params[:per_page] || (RAILS_ENV=='test' ? 1 : 40)).to_i
  end
  
  def set_profile
    @p = @u.profile if @u && @u.profile
    Time.zone = @p.time_zone if @p && @p.time_zone
    #@p.update_attribute :last_activity_at, Time.now if @p
  end
  
  # API objects that get built once per request
  def flickr(user_name = nil, tags = nil )
    @flickr_object ||= Flickr.new(FLICKR_CACHE, FLICKR_KEY, FLICKR_SECRET)
  end
  
  def flickr_images(user_name = "", tags = "")
    unless RAILS_ENV == "test"# || RAILS_ENV == "development"
      begin
        flickr.photos.search(user_name.blank? ? nil : user_name, tags.blank? ? nil : tags , nil, nil, nil, nil, nil, nil, nil, nil, 20)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end
  
  protected
  
  def allow_to level = nil, args = {}
    return unless level
    @level ||= []
    @level << [level, args]    
  end
  
  def check_permissions
    return failed_check_permissions if @p && !@p.is_active
    return true if @u && @u.is_admin
    raise '@level is blank. Did you override the allow_to method in your controller?' if @level.blank?
    @level.each do |l|
      next unless (l[0] == :all) || 
        (l[0] == :non_user && !@u) ||
        (l[0] == :user && @u) ||
        (l[0] == :owner && @p && @profile && @p == @profile)
      args = l[1]
      @level = [] and return true if args[:all] == true
      
      if args.has_key? :only
        actions = [args[:only]].flatten
        actions.each{ |a| @level = [] and return true if a.to_s == action_name}
      end
    end
    return failed_check_permissions
  end
  
  def failed_check_permissions
    flash[:error] = 'You don\'t have permission to view that page.'
    redirect_back_or_default home_path and return true
  end

  def not_found
    redirect_to "/" and return false
  end

  def logged_in
    !@u.nil? and !@u.new_record?
  end

  def load_filter_params
    @filter_params = Project.filter_param_select_opts
  end

  def load_sitewide_vars
    @unique_project_subscriptions = ProjectSubscription.find(:all, :group => "project_id")
    @total_funds_needed = 0

    @unique_project_subscriptions.each do |ps|
      @total_funds_needed += ps.project.capital_required
    end

    @total_reservations = @unique_project_subscriptions.size


    #TODO change this to pick up dynamic ipo
    @total_reservations_amount = ProjectSubscription.sum(:amount) * 5

    @pmf_fund_user = User.find(PMF_FUND_ACCOUNT_ID)

    @total_pmf_projects_invested_in = @pmf_fund_user.subscribed_projects.length
    @total_pmf_shares_reserved_all_projects = @pmf_fund_user.project_subscriptions.sum("amount")

    #TODO pick up dynamically ipo
    @total_pmf_shares_reserved_amount = @total_pmf_shares_reserved_all_projects * 5
  end

  def print_money value
    number_to_currency value
  end

  def check_captcha(redirect=nil)
    if !verify_recaptcha
      @message = "Please enter the captcha correctly!"
      if redirect
        flash[:error] = @message
      else
        flash.now[:error] = @message
      end
      false
    else
      true
    end
  end

  def redirect_to_home
    redirect_to :controller => "home"
  end

  def allowed_cancel_shares
    allowed_reserve_shares
  end

  def allowed_reserve_shares
    @project.owner != @u || @u.id == PMF_FUND_ACCOUNT_ID
  end

end
