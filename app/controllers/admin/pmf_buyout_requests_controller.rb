class Admin::PmfBuyoutRequestsController < Admin::AdminController

  before_filter :load_project, :except => "index"

  def index
    @open_requests = PmfShareBuyout.all_open | PmfShareBuyout.all_pending
    @denied_requests = PmfShareBuyout.all_denied
    @verified_requests = PmfShareBuyout.all_verified
  end

  def accept
    return unless request.post?

    if !@project.pmf_share_buyout
      flash[:error] = "There is no outstanding request for this project"
      redirect_to :action => "index" and return
    end

    #make pending
    @project.pmf_share_buyout.status = "Pending"
    @project.pmf_share_buyout.save!

    #send the user a notification mail
    begin
      PaymentsMailer.deliver_pmf_share_buyout_accepted @project.pmf_share_buyout, @project.owner.profile.email
    rescue Exception => exc
      logger.info "Error sending mail! #{exc.to_s}"
    end

    flash[:positive] = "You have accepted this request, you can now make a payment for it below!"
    redirect_to :action => "index"
  end

  def deny
    return unless request.post?

    if !@project.pmf_share_buyout
      flash[:error] = "There is no outstanding request for this project"
      redirect_to :action => "index" and return
    end

    #make pending
    @project.pmf_share_buyout.status = "Denied"
    @project.pmf_share_buyout.save!

    #send the user a notification mail
    begin
      PaymentsMailer.deliver_pmf_share_buyout_denied @project.pmf_share_buyout, @project.owner.profile.email
    rescue Exception => exc
      logger.info "Error sending mail! #{exc.to_s}"
    end

    flash[:positive] = "You have denied this request!"
    redirect_to :action => "index"
  end

  private

  def load_project
    begin
      @project = Project.find_single_public(params[:id]) unless params[:id].blank?
    rescue ActiveRecord::RecordNotFound
      @project = nil
    end

    if !@project
      flash[:error] = "Project Not Found"
      redirect_to :controller => "home"
    end
  end

  def set_selected_tab
    @selected_tab_name = "pmf_buyout_requests"
  end
  
end
