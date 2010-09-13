class ProfilesController < ApplicationController
  include ApplicationHelper
    
  before_filter :search_results, :only => :index
  before_filter :setup, :except => :index
  before_filter :load_profile_filter_params
  skip_filter :login_required, :only => [:index, :show, :portfolio, :friend_list]

  def index
    #@profiles could be set due to a search
    if !@profiles
      if @filter_param = params[:profile_filter_param]
        @sql = Profile.get_sql @filter_param

        @profiles = Profile.find_by_sql(@sql).paginate :page => (params[:page] || 1), :per_page=> 48
      else
        @profiles = Profile.find(:all, :order => "created_at DESC").paginate :page => (params[:page] || 1), :per_page=> 48
      end
    end
  end

  def show
    @followed_blogs = []

    if @p == @profile
      @followed_blogs  = Blog.all_for_user_producer_followings(@u).paginate :page => (params[:page] || 1), :per_page=> 15
    end

    render :action => "profile"
  end
  
  def portfolio
    if @p == @profile
      #users live project follow stream
      @blogs = Blog.all_for_user_followings @u
      @pmf_fund_comments = ProjectComment.latest_for_user_followings @u
      @admin_project_ratings = AdminProjectRating.latest_for_user_followings @u
      @pmf_project_subscriptions = PmfFundSubscriptionHistory.latest_for_user_followings @u

      @items = @blogs + @pmf_fund_comments + @admin_project_ratings + @pmf_project_subscriptions

      @items.sort! do |a,b|
        b.created_at <=> a.created_at
      end

      @items = @items.paginate :page => (params[:page] || 1), :per_page=> 15
    end

    #this users top projects (24 hour change)
    @top_projects = ProjectChangeInfoOneDay.top_five_change_for_user @profile.user

    @total_shares_reserved = @profile.user.project_subscriptions.sum("amount")
    
    #TODO pick up dynamically ipo
    @total_shares_reserved_amount = @total_shares_reserved * 5

    @user_projects = @profile.user.owned_public_projects.paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 10
    @user_subscriptions = @profile.user.subscribed_projects.paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 10
    @followed_projects = @profile.user.followed_projects :order => "created_at DESC", :page => (params[:page] || 1), :per_page=> 10
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
    @profile = Profile[params[:id]]
    @user = @profile.user
  end

  def search_results
    if params[:search]
      p = params[:search].dup
      @search_query = p.delete(:uq)
      @profiles = Profile.search((@search_query || ''), p).paginate:page => (params[:page] || 1), :per_page => 50
    end
  end

  def load_profile_filter_params
    @profile_filter_params = Profile.filter_param_select_opts
  end
end
