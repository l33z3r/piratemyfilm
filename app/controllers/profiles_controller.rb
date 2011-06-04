class ProfilesController < ApplicationController
  include ApplicationHelper
    
  prepend_before_filter :setup, :except => [:index, :portfolio_awaiting_payment]

  before_filter :search_results, :only => :index
  skip_filter :login_required, :only => [:index, :show, :portfolio, :friend_list]

  def index
    #@profiles could be set due to a search
    if !@profiles
      if @filter_param = params[:profile_filter_param]

        #are we filtering by membership
        @filter_membership_id = params[:profile_membership_filter_param]

        if @filter_membership_id
          @condition_clause = Profile.get_membership_condition_clause(@filter_membership_id)
        end

        @sql = Profile.get_sql @filter_param, @condition_clause

        @profiles = Profile.find_by_sql(@sql).paginate :page => (params[:page] || 1), :per_page=> 48
      else
        @profiles = Profile.find(:all, :order => "created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 48
      end
    end

    @profile_membership_filter_params = MembershipType.membership_select_opts
  end

  def show
    #load this users producer rating info
    @my_member_rating = MemberRatingHistory.find_by_member_id_and_rater_id(@profile.user, @u, :order => "created_at DESC", :limit => "1")
    @selected_my_member_rating = @my_member_rating ? [@my_member_rating.rating, @my_member_rating.rating.to_s] : [1, "1"]

    #check if user can rate this producer
    @allowed_to_rate = !@my_member_rating || @my_member_rating.created_at < Time.now.beginning_of_day

    #load rating select opts
    @rating_select_opts = MemberRating.rating_select_opts

    #load talent rating select opts
    @talent_rating_select_opts = TalentRating.rating_select_opts

    @selected_user_subnav_link = "my_profile"
    
    @blogs = Blog.user_blogs(@profile.user).paginate :page => (params[:page] || 1), :per_page=> 10
    
    render :action => "profile"
  end
  
  def portfolio
    #this users top projects (24 hour change)
    @top_projects = ProjectChangeInfoOneDay.top_five_change_for_user @profile.user

    @total_shares_reserved = @profile.user.project_subscriptions.sum("amount")
    
    #TODO pick up dynamically ipo
    @total_shares_reserved_amount = @total_shares_reserved * 5

    @user_projects = @profile.user.owned_public_projects
    @user_funded_projects = @profile.user.owned_public_funded_projects

    @user_non_funded_subscriptions = @profile.user.subscribed_non_funded_projects
    @user_funded_subscriptions = @profile.user.subscribed_funded_projects
    
    @selected_user_subnav_link = "my_portfolio"
  end

  def portfolio_awaiting_payment
    @profile = @u.profile

    @projects_awaiting_payment = @profile.user.subscribed_projects_awaiting_payment

    if @projects_awaiting_payment.size == 0
      flash[:error] = "No projects are awaiting payment of shares by you!"
      redirect_to profile_path(@profile)
    end
  end

  def friend_list
    @friend_type = params[:friend_type]

    #validate friend_type
    if @friend_type && Profile.friend_type_consts.include?(@friend_type.to_i)
      @user_profile_list = @profile.friends_list(@friend_type)
      @friend_type_string = Profile.friend_type_string(@friend_type)
    else
      flash[:error] = "Invalid Parameter"
      redirect_to :controller => "/home" and return
    end
  end
  
  def edit
    @notification_types = Notification.all_types
    render
  end
  
  def update
    case params[:switch]
    when 'name','image'
      if @profile.update_attributes params[:profile]
        flash[:notice] = "Settings have been saved."
        redirect_to profile_url(@profile)
      else
        flash.now[:error] = @profile.errors
        render :action => :edit
      end
    when 'password'
      if @user.change_password(params[:verify_password], params[:new_password], params[:confirm_password])
        flash[:notice] = "Password has been changed."
        redirect_to edit_profile_url(@profile)
      else
        flash.now[:error] = @user.errors
        render :action=> :edit
      end
    else
      RAILS_ENV == 'test' ? render( :text=>'') : raise( 'Unsupported swtich in action')
    end
  end

  def delete_icon
    respond_to do |wants|
      @p.update_attribute :icon, nil
      wants.js {render :update do |page| page.visual_effect 'Puff', 'profile_icon_picture' end  }
    end      
  end

  private
  
  def allow_to
    super :owner, :all => true
    super :all, :only => [:show, :index, :search, :portfolio]
  end
  
  def setup
    if params[:userlogin]
      @user = User.find_by_login(params[:userlogin])
      @profile = @user.profile if @user
    else
      @profile = Profile.find(params[:id])
      @user = @profile.user
    end

    if @user.nil?
      flash[:error] = "Profile not found"
      redirect_to :controller => root_path
    end
  end

  def search_results
    if params[:search]
      p = params[:search].dup
      @search_query = p.delete(:uq)
      @profiles = Profile.search((@search_query || ''), p).paginate:page => (params[:page] || 1), :per_page => 50
    end
  end
end
