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

  def window_closed(sent_at = Time.now)
    subject    'PaymentsMailer#window_closed'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def payment_succeeded(sent_at = Time.now)
    subject    'PaymentsMailer#payment_succeeded'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

  def payment_defaulted(sent_at = Time.now)
    subject    'PaymentsMailer#payment_defaulted'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
