class UserTalentsController < ApplicationController

  skip_before_filter :login_required, :only => [:index]
  
  def index
    if params[:talent_filter_param]
      @talent_type_id = params[:talent_filter_param].to_i
    else
      @talent_type_id = 1
    end

    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]

    @talents = nil

    if @talent_type_name
      @talents = UserTalent.all_for_talent_type(@talent_type_name)
    else
      flash[:error] = "Cannot find that talent!"
      redirect_to home_path
    end
  end

  def talent_select_list
    if params[:talent_filter_param]
      @talent_type_id = params[:talent_filter_param].to_i
    else
      @talent_type_id = 1
    end

    @talent_type_name = UserTalent.talent_types_map[@talent_type_id]

    @talents = nil

    #need the project for the popup
    @project = Project.find(params[:project_id])
    
    if @talent_type_name
      @talents = UserTalent.all_for_talent_type(@talent_type_name)
    else
      flash[:error] = "Cannot find that talent!"
      redirect_to home_path
    end
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
        @user_talent = @u.talent(@talent_type_id)

        #make sure the user is not part of a project
        if !Project.find_all_for_talent_id(@user_talent.id).empty?
          flash[:error] = "You cannot un-register from this talent, as you are currently enlisted in a project!"
          redirect_to profile_path(@u.profile) and return
        end
        
        @user_talent.destroy
        flash[:positive] = "You are no longer registered as #{@talent_type_name.humanize.titleize} for projects!"
      else
        flash[:error] = "You are not registered as #{@talent_type_name.humanize.titleize} for projects, to be able to un-register!"
      end
    end

    redirect_to profile_path(@u.profile)
  end

  def rate
    return if !request.post?
    
    begin
      @user_talent_id = params[:user_talent_id]

      begin
        @user_talent = UserTalent.find @user_talent_id
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "You have already rated this talent today!"
        redirect_to :controller => "profiles" and return
      end

      @my_talent_rating = @u.talent_rating(@user_talent.talent_rating_id)

      if @my_talent_rating && !@u.can_talent_rate(@user_talent.talent_rating_id)
        flash[:error] = "You have already rated this talent today!"
        redirect_to :controller => "profiles", :action => "show", :id => @user_talent.user.profile.id and return
      end

      @current_talent_rating = TalentRating.find_by_user_talent_id @user_talent.id

      if !@current_talent_rating
        @current_talent_rating = TalentRating.create(:user_talent => @user_talent, :average_rating => 0)
      end

      #Get all talent rating historys
      @talent_rating_histories = TalentRatingHistory.find_all_by_talent_rating_id @current_talent_rating.id

      @rating = params[:rating].to_f

      #update the running average
      @alpha = 1.0/(@talent_rating_histories.size + 1)
      @current_sample = @rating
      @current_avg = @current_talent_rating.average_rating

      #formula for updating running avg
      @new_avg = ((1 - @alpha) * @current_avg) + (@alpha * @current_sample)

      @current_talent_rating.average_rating = @new_avg
      @current_talent_rating.save!

      #add the new sample
      TalentRatingHistory.create(:user => @u, :rating => @rating,
        :talent_rating => @current_talent_rating)

      flash[:positive] = "Talent Rated!"

      redirect_to :controller => "profiles", :action => "show", :id => @user_talent.user.profile.id
    rescue ActiveRecord::RecordInvalid
      flash[:error] = "Error rating talent!"
      redirect_to :controller => "profiles", :action => "show", :id => @user_talent.user.profile.id
    end
  end

  def allow_to
    super :all, :only => [:index]
    super :admin, :all => true
    super :user, :only => [:create, :destroy, :rate, :talent_select_list]
  end

end
