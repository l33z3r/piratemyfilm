class PaymentsMailer < ActionMailer::Base

  def window_opened payment_window, recipient
    @subject        = "Payment Window Opened For Project #{h payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def payment_succeeded payment_window, recipient
    @subject        = "Payment Received For Project #{h payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def window_closed_payment_succeeded payment_window, recipient
    @subject        = "Payment Window Closed For Project #{h payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def window_closed_payment_failed payment_window, recipient
    @subject        = "Payment Window Closed For Project #{h payment_window.project.title} On PMF"
    @recipients     = recipient
    @body['payment_window'] = payment_window
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

end
