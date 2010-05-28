class Admin::UsersController < Admin::AdminController
  before_filter :search_results, :except => [:destroy]

  def index
    @membership_select_opts = []

    @membership_types = MembershipType.find(:all)

    @membership_types.each do |@mt| 
      @membership_select_opts << [@mt.name, @mt.id.to_s]
    end
  end

  def update_membership
    begin
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "User not found"
    end

    begin
      @new_membership_type = MembershipType.find(params[:user_membership])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Membership type not found"
    end

    #delete old membership link
    @user.membership.membership_type = @new_membership_type
    @user.membership.save!

    flash[:positive] = "Membership type changed."
  end

#  def update
#    @profile = Profile.find(params[:id])
#    respond_to do |wants|
#      wants.js do
#        render :update do |page|
#          if @p == @profile
#            page << "message('You cannot deactivate yourself!');"
#          else
#            @profile.toggle! :is_active
#            page << "message('User has been marked as #{@profile.is_active ? 'active' : 'inactive'}');"
#            page.replace_html @profile.dom_id('link'), (@profile.is_active ? 'deactivate' : 'activate')
#          end
#        end
#      end
#    end
#  end
  
  private
  
  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @search_query = p.delete(:uq)
    @profiles = Profile.search((@search_query || ''), p).paginate:page => (params[:page] || 1), :per_page => 50
  end

  def set_selected_tab
    @selected_tab_name = "users"
  end

end