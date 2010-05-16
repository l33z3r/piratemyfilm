class Admin::UsersController < Admin::AdminController
  before_filter :search_results, :except => [:destroy]
  
  def index
    @membership_select_opts = []

    @membership_types = MembershipType.find(:all)

    @membership_types.each {  |@mt|
      @membership_select_opts << [@mt.name, @mt.id.to_s]
    }

    @membership_select_opts
  end

  def update_membership
    begin
      @new_membership_type = MembershipType.find(params[:user_membership])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Membership type not found"
      redirect_to :controller => "admin/users" and return
    end

    #delete old membership link
    @p.user.membership.destroy

    #create new link
    Membership.create(:user => @p.user, :membership_type => @new_membership_type)

    flash[:positive] = "Membership type changed."
    redirect_to :controller => "admin/users"
  end

  def update
    @profile = Profile.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if @p == @profile
            page << "message('You cannot deactivate yourself!');"
          else
            @profile.toggle! :is_active
            page << "message('User has been marked as #{@profile.is_active ? 'active' : 'inactive'}');"
            page.replace_html @profile.dom_id('link'), (@profile.is_active ? 'deactivate' : 'activate')
          end
        end
      end
    end
  end
  
  private
  
  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @search_query = p.delete(:q)
    @profiles = Profile.search((@search_query || ''), p).paginate:page => (params[:page] || 1), :per_page => 50
  end
end
