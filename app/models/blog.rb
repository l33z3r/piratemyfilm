# == Schema Information
# Schema version: 20100528091908
#
# Table name: blogs
#
#  id               :integer(4)    not null, primary key
#  title            :string(255)   
#  body             :text          
#  profile_id       :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#  is_homepage_blog :boolean(1)    
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
    if is_homepage_blog
      num_wp_comments
    else
      blog_comments.length
    end
  end
  def to_param
    "#{self.id}-#{title.to_safe_uri}"
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
      @blog.body = @blog.body.gsub(/<\/?[^>]*>/, "").gsub(/&#8216;/, "'").gsub(/&#8217;/, "'").gsub(/&#8211;/, "-")
      @blog.num_wp_comments = item.search("slash:comments").first.children.first.inner_text
      @blog.wp_comments_link = item.search("comments").first.children.first.inner_text
      @blog.is_homepage_blog = true
      @blog.profile_id = @max_profile_id unless @blog.profile_id
      @blog.created_at = @blog.updated_at = item.search("pubdate").first.children.first.inner_text
      @blog.save!



    end

    @new_hp_blogs = Blog.find_all_by_is_homepage_blog(true)
    puts "Updated Max Blog with " + @new_hp_blogs.length.to_s + " blogs!"
  end

end
