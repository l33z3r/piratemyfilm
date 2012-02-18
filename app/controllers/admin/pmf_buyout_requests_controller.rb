class Admin::PmfBuyoutRequestsController < Admin::AdminController

  before_filter :load_project, :except => "index"

  def index
    @open_requests = PmfShareBuyout.all_open | PmfShareBuyout.all_pending
    @denied_requests = PmfShareBuyout.all_denied
    @verified_requests = PmfShareBuyout.all_verified

    #load the paypal submission url
    @paypal_url = CUSTOM_CONFIG['paypal_button_submission_url']
     
    @checkoutDataMap = {}
      
    @open_requests.each do |orq|
      if !orq.project.bitpay_email.blank?
        @secret = BITPAY_SECRET
        @posData = "#{orq.id},#{Digest::MD5.hexdigest(@secret + orq.id.to_s)}"
    
        @orderID = orq.project.title + " buyout request"
        @price = 0.01#orq.payment_amount
    
        @currency = "BTC"
    
        @notificationURL = url_for(:controller => "/payment_window", :action => "bitpay_notify_buyout", :only_path => false)
        @redirectURL = root_url
    
        @email = orq.project.bitpay_email
    
        @data = {
          :email => @email,
          :posData => @posData,
          :orderID => @orderID,
          :price => @price,
          :currency => @currency,
          :notificationURL => @notificationURL,
          :redirectURL => @redirectURL
        }
    
        @data_json = @data.to_json
    
        @bitpay_cert_pem = File.read("#{Rails.root}/public/certs/bit-pay.com.crt")
    
        @cert = OpenSSL::X509::Certificate.new(@bitpay_cert_pem)
        @data_der = OpenSSL::PKCS7::encrypt([@cert], @data_json, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_der
    
        @data_der_encode64 = Base64.encode64(@data_der)
    
        @checkout_data = @data_der_encode64
        
        @checkoutDataMap[orq.id] = @checkout_data
      end
    end
    
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

    #still mark project as finished payment
    @project.mark_as_finished_payment
    @project.save!
    
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
