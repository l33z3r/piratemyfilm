class HomeController < ApplicationController
  skip_before_filter :login_required	

  def roll
    #    PaymentWindow.rollover_payment_window Project.find(4)

    Project.all.each do |p|
      PaymentWindow.rollover_payment_window p
    end
    
    render :text => "rolled"
  end
  
  def index
    @blogs = Blog.all_member_blogs
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15

    @blog = Blog.new
    
    #tell view that this is homepage (used for banner ad for now)
    @is_home_page = true
    
    @selected_subnav_link = "member_updates"
    
    render :template => "/blogs/all_member_blogs"
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
    flash[:error] = 'Seems that the page you were looking for does not exist!'
    redirect_to home_path
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