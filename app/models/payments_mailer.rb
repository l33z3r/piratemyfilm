class PaymentsMailer < ActionMailer::Base

  def window_opened payment_window, recipient
    @subject        = "Payment Window Opened For Project #{payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def payment_succeeded payment_window, recipient
    @subject        = "Payment Received For Project #{payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def window_closed_payment_succeeded payment_window, recipient
    @subject        = "Payment Window Closed For Project #{payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def window_closed_payment_failed payment_window, recipient
    @subject        = "Payment Window Closed For Project #{payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end
  
  def window_closed_payment_thrown payment_window, recipient
    @subject        = "Payment Window Closed For Project #{payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def pmf_share_buyout_denied pmf_share_buyout, recipient
    @subject        = "PMF Share Buyout Denied for Project #{pmf_share_buyout.project.title} on PMF"
    @recipients     = recipient
    @body['pmf_share_buyout'] = pmf_share_buyout
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def pmf_share_buyout_accepted pmf_share_buyout, recipient
    @subject        = "PMF Share Buyout Accepted for Project #{pmf_share_buyout.project.title} on PMF"
    @recipients     = recipient
    @body['pmf_share_buyout'] = pmf_share_buyout
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def buyout_request pmf_share_buyout
    @recipient = Profile.find(PMF_FUND_ACCOUNT_ID).email

    @subject        = "User Requesting a PMF Share Buyout!"
    @recipients     =  @recipient
    @body['pmf_share_buyout'] = pmf_share_buyout
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

end
