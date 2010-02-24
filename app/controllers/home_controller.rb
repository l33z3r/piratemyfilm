class HomeController < ApplicationController
  skip_before_filter :login_required	

  def index
    @filter_params = Project.filter_params
    @projects = Project.find_all_public(:order => "percent_funded DESC, rated_at DESC, created_at DESC", :limit => 10)
  end

  def newest_members
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end
  def latest_comments
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end

  def terms
    render
  end

  def alive
    render :text => "alive"
  end

  def contact
    return unless request.post?
    body = []
    params.each_pair { |k,v| body << "#{k}: #{v}"  }
    HomeMailer.deliver_mail(:subject=>"from #{SITE_NAME} contact page", :body=>body.join("\n"))
    flash[:notice] = "Thank you for your message.  A member of our team will respond to you shortly."
    redirect_to contact_url
  end

  private

  def allow_to 
    super :all, :all=>true
  end

end

class HomeMailer < ActionMailer::Base
  def mail(options)
    self.generic_mailer(options)
  end
end