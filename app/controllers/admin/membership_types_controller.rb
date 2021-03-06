class Admin::MembershipTypesController < Admin::AdminController
  
  def index
    @membership_types = MembershipType.all
    @select_options = MembershipType.select_options
    @min_funding_options = MembershipType.min_funding_options
    @funding_options = MembershipType.funding_options
  end

  def update
    @membership_type = MembershipType.find(params[:id])
    
    if @membership_type.update_attributes(params)
      User.apply_all_membership_limits
      flash[:notice] = 'Membership type was successfully updated.'
    else
      flash[:notice] = 'There was a problem with updating these parameters'
    end
    redirect_to :controller => "admin/membership_types"
  end

  private

  def set_selected_tab
    @selected_tab_name = "membership_types"
  end

end
