class HomeController < ApplicationController
  skip_before_filter :login_required	

  before_filter :search_results, :only => [:search]
  
  def index
    @blogs = Blog.all_member_blogs
    @blogs = @blogs.paginate :page => (params[:page] || 1), :per_page=> 15

    @blog = Blog.new
    
    #tell view that this is homepage (used for banner ad for now)
    @is_home_page = true
    
    @selected_subnav_link = "member_updates"
    
    render :template => "/blogs/all_member_blogs"
  end

  def search
    render
  end
  
#  def newest_members
#    respond_to do |wants|
#      wants.html {render :action=>'index'}
#      wants.rss {render :layout=>false}
#    end
#  end
#  def latest_comments
#    respond_to do |wants|
#      wants.html {render :action=>'index'}
#      wants.rss {render :layout=>false}
#    end
#  end

  def alive
    render :text => "alive"
  end

  def fourohfour
    flash[:error] = 'Seems that the page you were looking for does not exist!'
    redirect_to home_path
  end

  private

  def search_results
    if params[:search]
      p = params[:search].dup
    else
      p = []
    end
    @search_string = p.delete(:q) || ''
    
    @search_type = params[:search_type] ? params[:search_type] : "projects"
    
    if @search_type == "users"
      @results = Profile.search(@search_string, p).paginate(:page => @page, :per_page => @per_page)
    else
      @results = Project.search(@search_string, p).paginate(:page => @page, :per_page => @per_page)
    end
  end

  def allow_to 
    super :all, :all=>true
  end

end

class HomeMailer < ActionMailer::Base
  def mail(options)
    self.generic_mailer(options)
  end
end