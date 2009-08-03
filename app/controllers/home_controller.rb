class HomeController < ApplicationController
  skip_before_filter :login_required	

  def contact
    return unless request.post?
    body = []
    params.each_pair { |k,v| body << "#{k}: #{v}"  }
    HomeMailer.deliver_mail(:subject=>"from #{SITE_NAME} contact page", :body=>body.join("\n"))
    flash[:notice] = "Thank you for your message.  A member of our team will respond to you shortly."
    redirect_to contact_url    
  end
 
  def index
    @recent_projects = Project.find_all_public(:order => "rated_at DESC, created_at DESC", :limit => 8)
    @recent_blogs = Blog.find_all_by_is_homepage_blog(true)

    @entries = []
    
    @recent_projects.each do |project|
      @entries << project
    end

    @recent_blogs.each do |blog|
      @entries << blog
    end

    @entries.sort! { |a,b| b.created_at <=> a.created_at }
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