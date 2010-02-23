class Admin::MembershipTypesController < Admin::AdminController
  
  def index
    @membership_types = MembershipType.all
    @select_options = MembershipType.select_options
    @funding_options = MembershipType.funding_options
  end

  def update
    @membership_type = MembershipType.find(params[:id])
    
    if @membership_type.update_attributes(params)
      check_for_unlimited(params, @membership_type)
      flash[:notice] = 'Membership type was successfully updated.'
    else
      flash[:notice] = 'There was a problem with updating these parameters'
    end
    redirect_to :controller => "admin/membership_types"
  end

  private

  def check_for_unlimited(params, membership_type)
    params.each do |param|
      if param[1] == "unlimited"
        membership_type.update_unlimited_param(param[0])
      end
    end
  end

end