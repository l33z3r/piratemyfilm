class ProjectsMailer < ActionMailer::Base
  
  def follow_invitation inviter, project, recipient
    @subject        = "Invite to Follow a Project on PMF"
    @recipients     = recipient
    @body['inviter']   = inviter
    @body['project']   = project
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
    @headers        = {}
    content_type "text/html"
  end

end
