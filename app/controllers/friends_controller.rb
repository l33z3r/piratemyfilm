class FriendsController < ApplicationController
  before_filter :setup
  skip_before_filter :login_required, :only => :index
  skip_before_filter :store_location, :only => [:create, :destroy]

  def create
    if Friend.make_friends(@p, @profile)
      #not sure why this is here
      friend = @p.reload.friend_of? @profile

      respond_to do |format|
        format.js do
          render :update do |page|
            page.replace @p.dom_id(@profile.dom_id + '_friendship_'), get_friend_link( @p, @profile)
          end
        end

        format.html do
          flash[:positive] = "You are now following #{@profile.user.f}"
          redirect_to profile_path @profile and return
        end
      end
    else
      @message = "Oops... That didn't work. Try again!"

      render :update do |page|
        page.alert @message
      end
    end
    
  end
  
  def destroy
    Friend.reset @p, @profile

    flash[:positive] = "You are no longer following #{@profile.user.f}"
    redirect_to profile_path @profile and return
    #    render :update do |page|
    #      #not sure why this is here
    #      following = @p.reload.following? @profile
    #
    #      page.replace @p.dom_id(@profile.dom_id + '_friendship_'), get_friend_link( @p, @profile)
    #    end
  end
  
  protected
  
  def allow_to
    super :user, :all => true
    super :non_user, :only => :index
  end
  
  def setup
    @profile = Profile[params[:id] || params[:profile_id]]
    @user = @profile.user
  end
  
end
