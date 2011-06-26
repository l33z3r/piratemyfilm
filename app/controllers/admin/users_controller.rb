class Admin::UsersController < Admin::AdminController
  before_filter :search_results, :except => [:destroy]

  def index
    @membership_select_opts = MembershipType.membership_select_opts

    @membership_type_filter_params = []
    @membership_type_filter_params += @membership_select_opts
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
      prepare_update_confirm_vars
      render :action => "confirm_update" and return
    end

    #delete old membership link
    @user.membership.membership_type = @new_membership_type
    @user.membership.save!

    #apply the new membership restrictions
    @user.apply_membership_limits

    flash[:positive] = "Membership type changed."
  end
  
  def update_mkc_post_ability
    @user = User.find(params[:user_id])
    @user.mkc_post_ability = params[:mkc_post_ability] ? true : false
    @user.save!
    
    flash[:positive] = "Setting updated!"
    redirect_to :action => "index"
  end
  
  def login_as
    return unless request.post?
    
    @user_id = params[:user_id]
    @user = User.find(@user_id)
    session[:user] = @user_id
    flash[:notice] = "Logged in as #{@user.login}!"
    redirect_to home_path
  end
  
  private

  def prepare_update_confirm_vars
    #load vars for confirmation popup
   
    @num_projects_delete = @num_projects_shares_over = 0
    @num_projects_exceeding_share_limit = @num_projects_exceeding_budget_limit = 0
    @num_projects_under_budget_limit = 0
    
    @user_projects = @user.owned_public_projects
    @num_projects_delete = @user_projects.length - @new_membership_type.max_projects_listed

    #how many projects has the user got shares in that will need to be revoked
    @num_projects_shares_over = @user.projects_with_shares_over(@new_membership_type.pc_limit)

    #how many projects has the user got shares in, and does it exceed the
    #total amount of projects they are allowed to hold shares in
    @num_projects_exceeding_share_limit = @user.subscribed_non_funded_projects.length - @new_membership_type.pc_project_limit

    #how many projects exceed the budget limit
    @num_projects_exceeding_budget_limit = @user.projects_exceeding_budget_limit(@new_membership_type.funding_limit_per_project)

    #how many projects under the budget limit
    @num_projects_under_budget_limit = @user.projects_under_budget_limit(@new_membership_type.min_funding_limit_per_project)
  end
  
  def search_results
    @membership_type_filter = params[:membership_filter_param]

    if @membership_type_filter && @membership_type_filter != "0"
      @membership_type_name = MembershipType.find(@membership_type_filter).name
      @find_conditions = {:include => [{:user => :membership_type}], :conditions => ['membership_types.id = ?', @membership_type_filter]}
    else
      @membership_type_name = "All"
      @find_conditions = {}
    end

    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @search_query = p.delete(:uq)
    
    if @search_query.blank?
      @profiles = Profile.find(:all, @find_conditions)
    else
      @profiles = Profile.search((@search_query || ''), p, @find_conditions)
    end
    
    @profiles = @profiles.paginate:page => (params[:page] || 1), :per_page => 50
  end

  def set_selected_tab
    @selected_tab_name = "users"
  end

end