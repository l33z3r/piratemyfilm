class UserTalentController < ApplicationController
  
  def index
  end

  def create
    @talent_type_id = params[:talent_type_id]
    
    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]
    
    if @talent_type_name
      if !@u.has_talent? @talent_type_id
        UserTalent.create(:user => @u, :talent_type => @talent_type_name)
        flash[:positive] = "You are now registered as a #{@talent_type_name}"
      else
        flash[:error] = "You are already registered as a #{@talent_type_name}"
      end
    end

    redirect_to profile_path(@u.p)
  end

  def destroy
    @talent_type_id = params[:talent_type_id]

    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]

    if @talent_type_name
      if @u.has_talent? @talent_type_id
        @u.talent(@talent_type_id).destroy!
        flash[:positive] = "You are no longer registered as a #{@talent_type_name}"
      else
        flash[:error] = "You are not registered as a #{@talent_type_name}, to be able to un-register!"
      end
    end

    redirect_to profile_path(@u.p)
  end

  def allow_to
    super :all, :only => [:index, :show, :blogs, :search, :filter_by_param]
    super :admin, :all => true
    super :user, :only => [:new, :create, :edit, :update, :delete, :delete_icon,
      :share_queue, :invite_friends, :send_friends_invite, :buy_shares]
  end

end
