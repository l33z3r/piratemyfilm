class ProjectsMailer < ActionMailer::Base
  
  def friend_invite sender, project, recipient
    @subject        = "Follow notice from #{SITE_NAME}"
    @recipients     = recipient
    @body['inviter']   = inviter
    @body['invited']   = invited
    @body['description'] = description
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
  end

end
