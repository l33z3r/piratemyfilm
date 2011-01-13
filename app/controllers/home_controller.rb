class HomeController < ApplicationController
  skip_before_filter :login_required	

  def index
    #global live stream
    @blogs = Blog.all_blogs
    @pmf_fund_comments = ProjectComment.latest
    @admin_project_ratings = AdminProjectRating.latest
    @pmf_project_subscriptions = PmfFundSubscriptionHistory.latest

    @items = @blogs + @pmf_fund_comments + @pmf_project_subscriptions + @admin_project_ratings

    @items.sort! do |a,b|
      b.created_at <=> a.created_at
    end

    @items = @items.paginate :page => (params[:page] || 1), :per_page=> 15
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