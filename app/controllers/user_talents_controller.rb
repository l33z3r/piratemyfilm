class UserTalentsController < ApplicationController
  
  def index
    if params[:talent_filter_param]
      @talent_type_id = params[:talent_filter_param].to_i
    else
      @talent_type_id = 1
    end

    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]

    @talents = nil

    if @talent_type_name
      @talents = UserTalent.find_all_by_talent_type(@talent_type_name)
    else
      flash[:error] = "Cannot find that talent!"
      redirect_to home_path
    end

    @talent_filter_params = UserTalent.filter_param_select_opts
  end

  def create
    return if !request.post?
    
    @talent_type_id = params[:talent_type_id].to_i
    
    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]
    
    if @talent_type_name
      if !@u.has_talent? @talent_type_id
        UserTalent.create(:user => @u, :talent_type => @talent_type_name)
        flash[:positive] = "You are now registered as #{@talent_type_name.humanize.titleize} for projects!"
      else
        flash[:error] = "You are already registered as #{@talent_type_name.humanize.titleize} for projects!"
      end
    end

    redirect_to profile_path(@u.profile)
  end

  def destroy
    return if !request.delete?

    @talent_type_id = params[:talent_type_id].to_i

    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]

    if @talent_type_name
      if @u.has_talent? @talent_type_id
        @u.talent(@talent_type_id).destroy
        flash[:positive] = "You are no longer registered as #{@talent_type_name.humanize.titleize} for projects!"
      else
        flash[:error] = "You are not registered as #{@talent_type_name.humanize.titleize} for projects, to be able to un-register!"
      end
    end

    redirect_to profile_path(@u.profile)
  end

  def allow_to
    super :all, :only => [:index, :show, :blogs, :search, :filter_by_param]
    super :admin, :all => true
    super :user, :only => [:new, :create, :edit, :update, :delete, :delete_icon,
      :share_queue, :invite_friends, :send_friends_invite, :buy_shares]
  end

end
