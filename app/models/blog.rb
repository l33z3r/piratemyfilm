class Blog < ActiveRecord::Base
  has_many :comments, :as => :commentable, :order => "created_at asc"
  belongs_to :profile

  has_many :blog_user_mentions, :dependent => :destroy
  
  belongs_to :project

  belongs_to :blog, :foreign_key => "blog_rebuzz_id"
  
  has_many :blog_comments

  belongs_to :project_user_talent
  belongs_to :blog_rebuzz, :class_name => "Blog"
  
  after_save :create_blog_user_mentions
  before_save :parse_urls
  
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
  
  def user_relationship the_profile
    @rel_text = ""
    if project
      if project_user_talent
        @rel_text += "(#{project_user_talent.user_talent.talent_type.titleize})"
      elsif project.owner.id == the_profile.user.id
        @rel_text += "(Owner)"
      else
        @rel_text += "(Shareholder)"
      end 
    end
    
    @rel_text
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
      profile_id in (select inviter_id from friends
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
  
  def self.prepare_rebuzz blog
    @rebuzzed_blog = Blog.find(blog.blog_rebuzz_id)
      
    blog.project_user_talent_id = @rebuzzed_blog.project_user_talent_id
    blog.project_id = @rebuzzed_blog.project_id
      
    blog.title = @rebuzzed_blog.title
    blog.body = @rebuzzed_blog.body
  end
  
  def create_blog_user_mentions
    @mentions = body.scan(/@\w+/)
    
    @mentions.each do |mention|
      @user_login = mention[1..mention.length-1]
      @user_mentioned = User.find_by_login(@user_login)
      
      if @user_mentioned 
        #does an obj already exist
        if !blog_user_mentions.find_by_user_id(@user_mentioned.id)
          blog_user_mentions.build(:user_id => @user_mentioned.id).save
        end
      end
    end
  end
  
  def parse_urls
    return if blog_rebuzz_id
    
    @shortened_urls = {}
    
    @youtube_url_http = "http://www.youtube.com"
    @youtube_url_https = "https://www.youtube.com"
    
    #try to shorten the url, it may fail, but we dont care for now
    #this also deals with urls that are already bitly shortened
    URI.extract(body).each do |url|
      begin
        if url.starts_with? @youtube_url_http or url.starts_with? @youtube_url_https
          #replace with an embed
          
          @vid_id_start_index = url.index("v=") + 2
          @vid_id_end_index = url.index("&", @vid_id_start_index)
          
          if !@vid_id_end_index 
            @vid_id_end_index = url.length
          end
          
          @vid_id = url[@vid_id_start_index..@vid_id_end_index - 1]
          
          @vid_embed_html = "<iframe align='center' width='300' height='200'
                    src='http://www.youtube.com/embed/#{@vid_id}'
                    frameborder='0'>
            </iframe>"
          
          body.gsub!(url, @vid_embed_html)
        else
          @shortened_urls[url] = BITLY.shorten(url).short_url
        end
      rescue 
      end
    end
    
    @shortened_urls.each do |url, shortened_url|
      body.gsub!(url, shortened_url)
    end
  end
  
  def body_length_before_bitly
    @chars_per_link = 24
    
    @extracted_links = URI.extract(body)
    @old_link_char_count = @extracted_links.join.length
    @new_link_char_count = @extracted_links.length * @chars_per_link
    
    @body_length = (body.length - @old_link_char_count) + @new_link_char_count
    
    @body_length
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
#  blog_rebuzz_id         :integer(4)
#

