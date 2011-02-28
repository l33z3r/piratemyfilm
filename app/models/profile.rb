# == Schema Information
# Schema version: 20110110160522
#
# Table name: profiles
#
#  id               :integer(4)    not null, primary key
#  user_id          :integer(4)    
#  first_name       :string(255)   
#  last_name        :string(255)   
#  website          :string(255)   
#  blog             :string(255)   
#  flickr           :string(255)   
#  about_me         :text          
#  aim_name         :string(255)   
#  gtalk_name       :string(255)   
#  ichat_name       :string(255)   
#  icon             :string(255)   
#  location         :string(255)   
#  created_at       :datetime      
#  updated_at       :datetime      
#  email            :string(255)   
#  is_active        :boolean(1)    
#  youtube_username :string(255)   
#  flickr_username  :string(255)   
#  last_activity_at :datetime      
#  time_zone        :string(255)   default("UTC")
#  country_id       :integer(4)    default(1)
#

class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :country

=begin
  TODO move is_Active to user
  rename it to active
=end
  attr_protected :is_active
  attr_immutable :id
  
  validates_format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message=>'does not look like an email address.'
  validates_length_of :email, :within => 3..100
  validates_uniqueness_of :email, :case_sensitive => false
  
  validates_filesize_of :icon, {:in => 0.kilobytes..1.megabyte, :message => "Your Profile Image must be less than 1 megabyte"}

  # Feeds
  has_many :feeds
  has_many :feed_items, :through => :feeds, :order => 'created_at desc'
  has_many :private_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => false}, :order => 'created_at desc'
  has_many :public_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => true}, :order => 'created_at desc'
  
  # Messages
  has_many :sent_messages,     :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'receiver_id'
  has_many :unread_messages,   :class_name => 'Message', :conditions => {:read => false}, :foreign_key => 'receiver_id'

  # Friends
  has_many :friendships, :class_name  => "Friend", :foreign_key => 'inviter_id', :conditions => "status = #{Friend::ACCEPTED}"
  has_many :follower_friends, :class_name => "Friend", :foreign_key => "invited_id", :conditions => "status = #{Friend::PENDING}"
  has_many :following_friends, :class_name => "Friend", :foreign_key => "inviter_id", :conditions => "status = #{Friend::PENDING}"
  
  has_many :friends,   :through => :friendships, :source => :invited
  has_many :followers, :through => :follower_friends, :source => :inviter
  has_many :followings, :through => :following_friends, :source => :invited
  
  # Comments and Blogs
  has_many :comments, :as => :commentable, :order => 'created_at desc'
  has_many :blogs, :order => 'created_at desc'
  
  # Photos
  has_many :photos, :order => 'created_at DESC'
  
  #Forums
  has_many :forum_posts, :foreign_key => 'owner_id', :dependent => :destroy
  
  acts_as_ferret :fields => [ :location, :f, :about_me, :user_login ], :remote => true
  
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }
  
  cattr_accessor :featured_profile
  @@featured_profile = {:date=>Date.today-4, :profile=>nil}
  Profile::NOWHERE = 'Nowhere'

  def to_param
    "#{self.id}-#{f.to_safe_uri}"
  end
  
  def has_network?
    !Friend.find(:first, :conditions => ["invited_id = ? or inviter_id = ?", id, id]).blank?
  end

  #Friend types
  FOLLOWERS = 1
  FOLLOWINGS = 2
  FRIENDS = 3

  @@friend_type_consts = [FOLLOWERS, FOLLOWINGS, FRIENDS]

  def self.friend_type_consts
    @@friend_type_consts
  end

  def self.friend_type_string friend_type
    case friend_type.to_s
    when "1" then return "Followers"
    when "2" then return "Followings"
    when "3" then return "Friends"
    else return nil
    end
  end

  def friends_list type
    case type.to_s
    when "1" then return followers
    when "2" then return followings
    when "3" then return friends
    else return nil
    end
  end

  # Friend Methods
  def friend_of? user
    user.in? friends
  end

  def followed_by? user
    user.in? followers
  end

  def following? user
    user.in? followings
  end
    
  def f
    if self.first_name.blank? && self.last_name.blank?
      user.login rescue 'Deleted user'
    else
      ((self.first_name || '') + ' ' + (self.last_name || '')).strip
    end
  end

  def user_login
    user.login
  end
  
  def location
    return Profile::NOWHERE if attributes['location'].blank?
    attributes['location']
  end

  def home_country
    country ? country : nil
  end

  def home_country_select_opt
    country ? [country.name, country.id] : nil
  end
  
  def full_name
    f
  end
  
  def self.featured
    find_options = {
      :include => :user,
      :conditions => ["is_active = ? and about_me IS NOT NULL and user_id is not null", true],
    }
    #    find(:first, find_options.merge(:offset => rand( count(find_options) - 1)))
    find(:first, find_options.merge(:offset => rand(count(find_options)).floor)) 
  end  
  
  def no_data?
    (created_at <=> updated_at) == 0
  end

  def has_wall_with profile
    return false if profile.blank?
    !Comment.between_profiles(self, profile).empty?
  end
  
  def website= val
    write_attribute(:website, fix_http(val))
  end

  def blog= val
    write_attribute(:blog, fix_http(val))
  end

  def flickr= val
    write_attribute(:flickr, fix_http(val))
  end

  def notification_type_ids
    user.notifications.collect(&:notification_type_id)
  end

  def notification_type_ids=(ids)
    #clear all notifications first
    Notification.destroy(user.notifications.collect(&:id))

    ids.each do |id|
      Notification.find_or_create_by_user_id_and_notification_type_id(user.id, id)
    end
  end

  def self.search query = '', options = {}, conditions = {}
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = find_by_contents q, {:limit=>:all}, conditions
    logger.debug arr.inspect
    arr
  end

  @@filter_params_map = {
    1 => "View Members By...", 2 => "User Login",
    3 => "No. Projects Listed", 4 => "No. Shares Reserved", 5 => "Producer Rating"
  }

  def self.get_sql filter_param, condition_clause

    condition_clause = "" if !condition_clause

    case filter_param
    when "2" then 
      return "select profiles.* from profiles join users on profiles.user_id = users.id 
        join memberships on profiles.user_id = memberships.user_id
        #{condition_clause}
        order by users.login"
    when "3" then
      #need to put in either where or and keyword

      if condition_clause.length == 0
        condition_clause = "where "
      else
        condition_clause += " and "
      end

      return "select profiles.*, count(projects.id) as projects_count from profiles
        join users on profiles.user_id = users.id left join projects on projects.owner_id = users.id
        join memberships on profiles.user_id = memberships.user_id
        #{condition_clause}
        (projects.id is null or (projects.symbol IS NOT NULL and projects.is_deleted = 0))
        group by users.id
        order by projects_count DESC"
    when "4" then
      return "select profiles.*, sum(project_subscriptions.amount) as project_subscriptions_count
        from profiles join users on profiles.user_id = users.id left join project_subscriptions on
        project_subscriptions.user_id = users.id
        join memberships on profiles.user_id = memberships.user_id
        #{condition_clause}
        group by users.id order by
        project_subscriptions_count DESC"
    when "5" then
      return "select profiles.* from profiles join users on profiles.user_id = users.id
        left join member_rating_histories on profiles.user_id = member_rating_histories.member_id
        join memberships on profiles.user_id = memberships.user_id
        #{condition_clause}
        group by profiles.user_id
        order by users.member_rating DESC, count(member_rating_histories.member_id) DESC"
    else
      return "select profiles.* from profiles join users on profiles.user_id = users.id
        join memberships on profiles.user_id = memberships.user_id
        #{condition_clause} order by users.created_at DESC"
    end
  end
  
  @@membership_filter_params_map = {
    1 => "Please Choose...", 2 => "User Login", 
    3 => "No. Projects Listed", 4 => "No. Shares Reserved", 5 => "Producer Rating"
  }

  def self.get_membership_condition_clause(membership_id)
    begin
      #load the membership
      MembershipType.find(membership_id)

      @clause = "where memberships.membership_type_id = #{membership_id}"

    rescue ActiveRecord::RecordNotFound
      @clause = ""
    end

    @clause
  end

  def self.filter_param_select_opts
    @filter_param_select_opts = []

    @@filter_params_map.each {  |key, value|
      @filter_param_select_opts << [value, key.to_s]
    }

    @filter_param_select_opts.sort! { |arr1, arr2|
      arr2[1].to_i <=> arr1[1].to_i
    }

    @filter_param_select_opts.reverse!

    @filter_param_select_opts
  end

  def receiving_notification_type(required_notification_type_id)
    user.notifications.collect(&:notification_type_id).include?(required_notification_type_id)
  end
  
  protected

  def fix_http str
    return '' if str.blank?
    str.starts_with?('http') ? str : "http://#{str}"
  end
  
end
