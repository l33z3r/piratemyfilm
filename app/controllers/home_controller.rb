class HomeController < ApplicationController
  skip_before_filter :login_required	

  def index

    redirect_to :controller => "blogs", :action => "producer"

#    @projects = cache('hp_projects') do
#      Project.find_all_public(:order => "percent_funded DESC, rated_at DESC, created_at DESC").paginate :page => 1, :per_page=> 15
#    end
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