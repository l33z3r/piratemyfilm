class NotificationsMailer < ActionMailer::Base
  
  def my_green_light project, recipient
    @subject        = "Green Light On Your Project!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def green_light project, recipient
    @subject        = "Project Given Green Light on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def project_listed project, recipient
    @subject        = "Project Listed on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def my_project_fully_funded project, recipient
    @subject        = "Your Project Is Now Fully Funded on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def project_fully_funded project, recipient
    @subject        = "Project Fully Funded on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def project_90_percent_funded project, recipient
    @subject        = "Project Is now 90% Funded on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def my_project_90_percent_funded project, recipient
    @subject        = "Your Project 90% Funded on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def my_pmf_rating_changed project, old_rating_symbol, new_rating_symbol, recipient
    @subject        = "Rating Changed On Your Project on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @body['old_rating_symbol'] = old_rating_symbol
    @body['new_rating_symbol'] = new_rating_symbol
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

  def pmf_rating_changed project, old_rating_symbol, new_rating_symbol, recipient
    @subject        = "Rating Changed on Project on PMF!"
    @recipients     = recipient
    @body['project'] = project
    @body['old_rating_symbol'] = old_rating_symbol
    @body['new_rating_symbol'] = new_rating_symbol
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

end
