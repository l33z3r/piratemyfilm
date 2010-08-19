class ProfilesController < ApplicationController
  include ApplicationHelper
  prepend_before_filter :get_profile, :except => [:new, :create, :index, :search]  
  before_filter :setup, :except => [:index, :search]
  before_filter :search_results, :only => [:index, :search]
  skip_filter :login_required, :only=>[:show, :index, :feed, :search]

  def show
    render :action => "profile"
  end
  
  def portfolio
    @total_shares_reserved = @profile.user.project_subscriptions.sum("amount")
    
    #TODO pick up dynamically ipo
    @total_shares_reserved_amount = @total_shares_reserved * 5

    @user_projects = @profile.user.owned_public_projects.paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 10
    @user_subscriptions = @profile.user.subscribed_projects.paginate :order=>"created_at DESC", :page => (params[:page] || 1), :per_page=> 10
  end

  def search
    render
  end
  
  def index
    render :action => :search
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

  private
  
  def allow_to
    super :owner, :all => true
    super :all, :only => [:show, :index, :search, :portfolio]
  end
  
  def get_profile
    @profile = Profile[params[:id]]
  end
  
  def setup
    @user = @profile.user
  end
  
  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @results = Profile.search((p.delete(:q) || ''), p).paginate(:page => @page, :per_page => @per_page)
  end
  
end
