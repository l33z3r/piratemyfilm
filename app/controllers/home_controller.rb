class HomeController < ApplicationController
  skip_before_filter :login_required	

  def index
    flash.keep
    redirect_to :controller => "blogs"
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

  def alive
    render :text => "alive"
  end

  def fourohfour
    flash[:notice] = 'Seems that the page you were looking for does not exist!'
    redirect_to :action => 'index'
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