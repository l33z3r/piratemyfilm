# == Schema Information
# Schema version: 20101115184046
#
# Table name: blogs
#
#  id               :integer(4)    not null, primary key
#  title            :string(255)   
#  body             :text          
#  profile_id       :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#  is_admin_blog    :boolean(1)    
#  project_id       :integer(4)    
#  num_wp_comments  :integer(4)    default(0)
#  wp_comments_link :string(255)   
#  guid             :string(255)   
#

class Blog < ActiveRecord::Base
  has_many :comments, :as => :commentable, :order => "created_at asc"
  belongs_to :profile
  validates_presence_of :title, :body
  attr_immutable :id, :profile_id

  belongs_to :project

  has_many :blog_comments

  def num_comments
    if is_mkc_blog
      num_wp_comments
    else
      blog_comments.length
    end
  end
  def to_param
    "#{self.id}-#{title.to_safe_uri}"
  end

  def is_producer_blog
    return project
  end

  def is_mkc_blog
    return guid
  end
  
  def self.update_max_blog

    @max_profile_id = CUSTOM_CONFIG['max_profile_id']
    @wordpress_feed_url = CUSTOM_CONFIG['mkc_wordpress_feed_url']
    
    puts "Updating Max Blog"
    doc = Hpricot(open(@wordpress_feed_url))

    (doc/:item).each do |item|
      @next_guid = item.search("guid").first.children.first.inner_text
      @blog = Blog.find_by_guid(@next_guid) || Blog.new()
      @blog.guid = @next_guid
      @blog.title = item.search("title").first.children.first.inner_text
      @blog.body = item.search("content:encoded").first.children.first.inner_text
      @blog.body = @blog.body.gsub(/<\/?[^>]*>/, "").gsub(/&#8216;/, "'").gsub(/&#8211;/, "-")
      @blog.body = @blog.body.gsub(/&#8220;/, "'").gsub(/&#8221;/, "'").gsub(/&#8217;/, "'")
      @blog.body = @blog.body.gsub(/&#8243;/, "'")
      @blog.num_wp_comments = item.search("slash:comments").first.children.first.inner_text
      @blog.wp_comments_link = item.search("comments").first.children.first.inner_text
      @blog.profile_id = @max_profile_id unless @blog.profile_id
      @blog.created_at = @blog.updated_at = item.search("pubdate").first.children.first.inner_text
      
      if @blog.body.strip!.length != 0
        @blog.save!
      end

    end

    @new_hp_blogs = Blog.mkc_blogs
    puts "Updated Max Blog with " + @new_hp_blogs.length.to_s + " blogs!"
  end

  def self.all_for_user_followings user

    @project_ids = []

    user.followed_projects.each do |project|
      @project_ids << project.id
    end

    return [] if @project_ids.size == 0

    find(:all, :include => :project, :conditions => "(projects.is_deleted = false and projects.symbol is not null)
        and projects.id in (#{@project_ids.join(",")})",
      :order => "blogs.created_at desc")
  end

  def self.all_for_user_producer_followings user

    @profile_ids = []

    @followed_profiles = user.profile.friends + user.profile.followings

    @followed_profiles.each do |profile|
      @profile_ids << profile.id
    end

    return [] if @profile_ids.size == 0

    find(:all, :include => :project, :conditions => "(projects.is_deleted = false and projects.symbol is not null)
        and blogs.profile_id in (#{@profile_ids.join(",")})",
      :order => "blogs.created_at desc")
  end

  def self.all_blogs
    find(:all, :include => :project, :conditions => "(projects.is_deleted = false and projects.symbol is not null)
        or (blogs.is_admin_blog = 1) or (blogs.guid is not null)",
      :order => "blogs.created_at desc")
  end

  def self.producer_blogs
    find(:all, :include => :project, :conditions => "guid is null and is_admin_blog = false and
      projects.symbol is not null and projects.is_deleted = false",
      :order=>"blogs.created_at DESC")
  end

  def self.user_blogs user
    @profile_id = user.profile.id

    find(:all, :include => :project, :conditions => "guid is null and is_admin_blog = false and
      projects.symbol is not null and projects.is_deleted = false and blogs.profile_id =  #{@profile_id}",
      :order=>"blogs.created_at DESC")
  end

  def self.admin_blogs
    find_all_by_is_admin_blog(true, :order => "created_at DESC")
  end

  def self.mkc_blogs
    find(:all, :conditions => "guid IS NOT NULL", :order => "created_at DESC")
  end

end
