class Blog < ActiveRecord::Base
  has_many :comments, :as => :commentable, :order => "created_at asc"
  belongs_to :profile
  validates_presence_of :body

  belongs_to :project

  has_many :blog_comments

  belongs_to :project_user_talent
  
  def num_comments
    if is_mkc_blog
      num_wp_comments
    else
      blog_comments.length
    end
  end
  
  def to_param
    "#{self.id}"
  end
  
  def user_relationship
    if project and project.owner.id == profile.user.id
      return "Owner"
    elsif project_user_talent
      return "#{project_user_talent.user_talent.talent_type.titleize}"
    else
      "Shareholder"
    end
  end

  def self.update_max_blog
    
    @wordpress_feed_url = CUSTOM_CONFIG['mkc_wordpress_feed_url']
    
    @wordpress_feed_url += "?z=#{Time.new.to_i}"
    
    puts "Updating Max Blog from url #{@wordpress_feed_url}"
    
    doc = Hpricot(open(@wordpress_feed_url))

    puts "Parsing #{(doc/:item).size} items"
    
    (doc/:item).each do |item|
      @next_guid = item.search("guid").first.children.first.inner_text
      
      puts "GUID: #{@next_guid}"
      
      @blog = Blog.find_by_guid(@next_guid) || Blog.new
      
      @blog.guid = @next_guid
      
      @blog.title = item.search("title").inner_html
      
      #replace problematic chars
      @blog.title = strip_problematic_chars @blog.title
      
      @blog.body = item.search("description").inner_text
      
      #replace problematic chars
      @blog.body = strip_problematic_chars @blog.body
      
      #strip white space
      @blog.body = @blog.body.strip
      
      @blog.num_wp_comments = item.search("slash:comments").first.children.first.inner_text
      @blog.wp_comments_link = item.search("comments").first.children.first.inner_text
      @blog.profile_id = nil
      @blog.created_at = @blog.updated_at = item.search("pubdate").first.children.first.inner_text
      
      puts "Saving blog with body: #{@blog.body[0..40]}"
      
      if @blog.body.length != 0
        @blog.save!
      end

    end

    @new_hp_blogs = Blog.mkc_blogs
    puts "Updated Max Blogs Feed with " + @new_hp_blogs.length.to_s + " blogs!"
  end
  
  def self.strip_problematic_chars thestring
    thestring = thestring.gsub(/<\/?[^>]*>/, "").gsub(/&#8216;/, "'").gsub(/&#8211;/, "-")
    thestring = thestring.gsub(/&#8220;/, "'").gsub(/&#8221;/, "'").gsub(/&#8217;/, "'")
    thestring = thestring.gsub(/&#8243;/, "'")
    thestring
  end
    
  #if its an admin blog the flag will be set in db
  def is_admin_blog
    super
  end
  
  #the guid of the blog on the wordpress mkc site will be set
  def is_mkc_blog
    return guid
  end
  
  #the following functions retrieve blogs for different feeds
  
  #public member feed
  def self.all_member_blogs
    #all blogs, including admin blogs and mkc blogs
    find(:all, :include => "project", 
      :conditions => "blogs.project_id is null or projects.is_deleted = false", :order => "blogs.created_at DESC")
  end
  
  #private member feed
  def self.my_followings user
    #all blogs that have been created by users that the user is following
    @mkc_blog_filter_sql = @admin_blog_filter_sql = nil
    
    if user.following_mkc_blogs
      @mkc_blog_filter_sql = "guid is not null"
    end
    
    if user.following_admin_blogs
      @admin_blog_filter_sql = "is_admin_blog is true"
    end
    
    @admin_mkc_blog_filter_sql = ""
    
    if @mkc_blog_filter_sql
      @admin_mkc_blog_filter_sql += "#{@mkc_blog_filter_sql} or "
    end
    
    if @admin_blog_filter_sql
      @admin_mkc_blog_filter_sql += "#{@admin_blog_filter_sql} or "
    end
    
    find_by_sql("select distinct blogs.* from blogs left outer join projects on projects.id = blogs.project_id 
      where #{@admin_mkc_blog_filter_sql} 
      (blogs.project_id is null or projects.is_deleted = false)
      and (profile_id in
      (select invited_id from friends where inviter_id = #{user.profile.id}) or
      profile_id = #{user.profile.id} or profile_id in (select inviter_id from friends
      where invited_id = #{user.id} and status = 1)) order by blogs.created_at desc")
  end
  
  #public project feed
  def self.all_project_blogs
    find(:all, :include => :project, 
      :conditions => "blogs.project_id is not null and projects.is_deleted = false",
      :order => "blogs.created_at desc")
  end
  
  #private project feed
  def self.all_for_user_followings user

    @project_ids = []

    user.followed_projects.each do |project|
      @project_ids << project.id
    end

    return [] if @project_ids.size == 0

    find(:all, :include => :project, :conditions => "(blogs.project_id is not null and projects.is_deleted = false)
        and projects.id in (#{@project_ids.join(",")})", :order => "blogs.created_at desc")
  end
  
  #mkc blogs
  def self.mkc_blogs
    find(:all, :conditions => "guid IS NOT NULL", :order => "created_at DESC")
  end
  
  #pmf fund blogs
  def self.admin_blogs
    find_all_by_is_admin_blog(true, :order => "created_at desc")
  end
  
  #users personal wall
  def self.user_blogs user
    @profile_id = user.profile.id

    find(:all, :include => "project", 
      :conditions => "(blogs.project_id is null or (blogs.project_id is not null and projects.is_deleted = false))
      and blogs.profile_id = #{@profile_id}", 
      :order => "blogs.created_at DESC")
  end
  
  #project page blogs
  def self.project_blogs project
    find(:all, :include => :project, 
      :conditions => "blogs.project_id is not null and projects.is_deleted = false
        and projects.id = #{project.id}", :order => "blogs.created_at desc")
  end
  
end

# == Schema Information
#
# Table name: blogs
#
#  id                     :integer(4)      not null, primary key
#  title                  :string(255)
#  body                   :text
#  profile_id             :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  is_admin_blog          :boolean(1)      default(FALSE)
#  project_id             :integer(4)
#  num_wp_comments        :integer(4)      default(0)
#  wp_comments_link       :string(255)
#  guid                   :string(255)
#  project_user_talent_id :integer(4)
#

