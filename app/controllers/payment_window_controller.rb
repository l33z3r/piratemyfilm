class PaymentWindowController < ApplicationController
  before_filter :load_project, :except => ["mark_payment", "show", "bitpay_notify", "bitpay_notify_buyout"]

  #we will manually check ownership in the mark_payment_paid action
  before_filter :check_owner_or_admin, :except => ["mark_payment", "show", "bitpay_notify", "bitpay_notify_buyout"]
  skip_filter :login_required, :only => [:bitpay_notify, :bitpay_notify_buyout]
  skip_before_filter :verify_authenticity_token, :only => [:bitpay_notify, :bitpay_notify_buyout]
  
  def pmf_buyout_request_paid
    #only allow post
    return unless request.post?

    #do not need to perform all the state checks for the project,
    #as they were done when the initial buyout request was created
    @project.pmf_share_buyout.status = "Verified"
    @project.pmf_share_buyout.save!

    @project.mark_as_finished_payment
    @project.save!
    
    flash[:positive] = "Payment Confirmed!"
    redirect_to :action => "history", :id => @project
  end

  def show
    begin
      @payment_window = PaymentWindow.find(params[:id])
      @project = @payment_window.project

      if @project.owner != @u && !@u.is_admin
        flash[:error] = 'You are not the owner of this project.'
        redirect_to project_path(@project) and return
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Payment Window Not Found"
      redirect_to :controller => "home"
    end
  end

  def show_current
    @payment_window = @project.current_payment_window

    if !@payment_window
      flash[:error] = "There is no active payment window for this project"
      redirect_to :action => "history", :id => @project and return
    end

    render :action => "show"
  end

  def history
    if !@project.in_payment? and !@project.finished_payment_collection
      flash[:error] = "This project is not in payment!"
      redirect_to project_path @project and return
    end
    
    @current_payment_window = @project.current_payment_window
    @previous_payment_windows = @project.payment_windows.find(:all, :conditions => "status != 'Active'")
  end

  def mark_payment
    #only allow post
    return unless request.post?

    #users can only mark as paid, the system will mark shares as defaulted when a payment window is closed
    begin
      @subscription_payment = SubscriptionPayment.find(params[:id])

      @project = @subscription_payment.project

      #manually check permissions
      if @project.owner != @u && !@u.is_admin
        flash[:error] = 'You are not the owner of this project.'
        redirect_to project_path(@project) and return
      end

      @payment_window = @subscription_payment.payment_window

      if !@payment_window.open?
        flash[:error] = "This payment window is not active"
        redirect_to :action => "history", :id => @project and return
      end

      if params[:marking] == "paid"
        if @subscription_payment.pending? or @subscription_payment.open?
          @subscription_payment.status = "Paid"

          #email the user whos payment has been marked as paid
          begin
            PaymentsMailer.deliver_payment_succeeded @payment_window, @subscription_payment.user.profile.email
          rescue Exception
            logger.info "Error sending mail!"
          end
    
          @subscription_payment.save!

        elsif @subscription_payment.paid?
          flash[:error] = "This payment has already been marked as Paid"
          redirect_to :action => "show_current", :id => @subscription_payment.project and return
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Subscription Payment Not Found"
      redirect_to :action => "show_current", :id => @subscription_payment.project and return
    end

    flash[:positive] = "Payment has been marked!"
    redirect_to :controller => "payment_window", :action => "show_current", :id => @subscription_payment.project.id
  end
  
  def bitpay_notify
    #    action: 'invoiceStatus'
    #    invoice_id: the bit-pay invoice id (that you see in the url for an invoice)
    #      amount: the amount of the invoice
    #      posData: the pos data you sent us in the encrypted checkoutData field
    #      status: either "confirmed" or "complete"

    BITPAY_CALLBACK_LOG.info "Received bitpay callback: " + params.inspect
    
    #only allow post
    render :inline => "Only post allowed" and return unless request.post?
    
    #check the hash
    @posData = params[:posData]
    
    @sp_id = @posData.split(",")[0]
    @md5hash = @posData.split(",")[1]
    
    @secret = BITPAY_SECRET
    @requiredMD5Hash = Digest::MD5.hexdigest(@secret + @sp_id.to_s)
    
    BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Comparing digest #{@requiredMD5Hash} to incoming: #{@md5hash}"
    
    if @md5hash.eql? @requiredMD5Hash
      BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Digest match!"
      
      @sp = SubscriptionPayment.find_by_id(@sp_id)
      
      if !@sp
        BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Cannot find subscription for id #{@sp_id}"
        render :inline => "Cannot find subscription for id #{@sp_id}" and return
      end
      
      @amount = params[:amount]
      @required_amount = @sp.share_amount * @sp.share_price
      
      BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Comparing required amount #{@required_amount} to incoming amount #{@amount}"

      if @amount.to_f >= @required_amount
        
        BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Amount match!"
        
        @status = params[:status]
        
        if @status.eql? "confirmed" or @status.eql? "complete"
          
          BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Status OK!"
          
          @payment_window = @sp.payment_window

          if !@payment_window or !@payment_window.open?
            BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: This payment window is not active!"
            render :inline => "This payment window is not active" and return
          end
          
          if @sp.pending? or @sp.open?
            @sp.status = "Paid"

            @sp.bitpay_invoice_id = params[:invoice_id]
            
            #email the user whos payment has been marked as paid
            begin
              PaymentsMailer.deliver_payment_succeeded @payment_window, @sp.user.profile.email
            rescue Exception
              logger.info "Error sending mail!"
            end
    
            @sp.save!

            BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: #{@sp.id} SUCCESSFULLY marked as Paid!"
            
          elsif @sp.paid?
            BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: This payment has already been marked as Paid!"
            render :inline => "This payment has already been marked as Paid" and return
          end
        else
          BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Status NOT OK!"
          render :inline => "Status not complete" and return
        end
      else
        BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Invalid amount."
        render :inline => "Invalid Amount" and return
      end
    else
      BITPAY_CALLBACK_LOG.info "INV #{params[:invoice_id]}: Invalid Digest"
      render :inline => "Invalid Digest" and return
    end
    
    render :inline => "OK"
  end
  
  def bitpay_notify_buyout
    #    action: 'invoiceStatus'
    #    invoice_id: the bit-pay invoice id (that you see in the url for an invoice)
    #      amount: the amount of the invoice
    #      posData: the pos data you sent us in the encrypted checkoutData field
    #      status: either "confirmed" or "complete"

    BITPAY_CALLBACK_LOG.info "ORQ Received bitpay callback: " + params.inspect
    
    #only allow post
    render :inline => "Only post allowed" and return unless request.post?
    
    #check the hash
    @posData = params[:posData]
    
    @orq_id = @posData.split(",")[0]
    @md5hash = @posData.split(",")[1]
    
    @secret = BITPAY_SECRET
    @requiredMD5Hash = Digest::MD5.hexdigest(@secret + @orq_id.to_s)
    
    BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Comparing digest #{@requiredMD5Hash} to incoming: #{@md5hash}"
    
    if @md5hash.eql? @requiredMD5Hash
      BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Digest match!"
      
      @orq = PmfShareBuyout.find_by_id(@orq_id)
      
      if !@orq
        BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Cannot find orq for id #{@orq_id}"
        render :inline => "Cannot find orq for id #{@orq_id}" and return
      end
      
      @amount = params[:amount]
      @required_amount = @orq.payment_amount
      
      BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Comparing required amount #{@required_amount} to incoming amount #{@amount}"

      if @amount.to_f >= @required_amount
        
        BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Amount match!"
        
        @status = params[:status]
        
        if @status.eql? "confirmed" or @status.eql? "complete"
          
          BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Status OK!"
          
          if @orq.project.pmf_share_buyout.status != "Verified"
            @orq.project.pmf_share_buyout.status = "Verified"
            @orq.project.pmf_share_buyout.bitpay_invoice_id = params[:invoice_id]
            
            @orq.project.pmf_share_buyout.save!

            @orq.project.mark_as_finished_payment
            @orq.project.save!
            
            BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Buyout successfully marked as paid!"
          else
            BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Share buyout ##{@orq.id} already verified!"
            render :inline => "Already verified" and return
          end
        else
          BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Status NOT OK!"
          render :inline => "Status not complete" and return
        end
      else
        BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Invalid amount."
        render :inline => "Invalid Amount" and return
      end
    else
      BITPAY_CALLBACK_LOG.info "ORQ INV #{params[:invoice_id]}: Invalid Digest"
      render :inline => "Invalid Digest" and return
    end
    
    render :inline => "OK"
  end

  protected

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

  def check_owner_or_admin
    if @project.owner != @u && !@u.is_admin
      flash[:error] = 'You are not the owner of this project.'
      redirect_to project_path(@project)
    end
  end

  def allow_to
    super :admin, :all => true
    super :user, :all => true
    super :all, :only => [:bitpay_notify, :bitpay_notify_buyout]
  end

end
