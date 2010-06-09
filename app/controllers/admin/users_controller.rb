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
      @error = true
      flash[:error] = "User not found" and return
    end

    begin
      @new_membership_type = MembershipType.find(params[:user_membership])
    rescue ActiveRecord::RecordNotFound
      @error = true
      flash[:error] = "Membership type not found" and return
    end

    @skip_confirm = (params[:skip_confirm] and !params[:skip_confirm].blank?)

    if !@skip_confirm
      #load vars for confirmation popup
      @user_projects = @user.owned_public_projects
      @num_projects_delete = @user_projects.length - @new_membership_type.max_projects_listed

      #how many projects has the user got shares in that will need to be revoked
      @num_projects_shares_over = @user.projects_with_shares_over @new_membership_type.pc_limit

      render :action => "confirm_update" and return
    end

    #delete old membership link
    @user.membership.membership_type = @new_membership_type
    @user.membership.save!

    flash[:positive] = "Membership type changed."
  end
  
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