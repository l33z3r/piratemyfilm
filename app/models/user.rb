# == Schema Information
# Schema version: 20110110160522
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  login                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  is_admin                  :boolean(1)    
#  can_send_messages         :boolean(1)    default(TRUE)
#  email_verification        :string(255)   
#  email_verified            :boolean(1)    
#  member_rating             :integer(4)    default(0)
#


require 'digest/sha1'
require 'mime/types'

class User < ActiveRecord::Base
  has_one :membership, :dependent => :destroy
  has_one :membership_type, :through => :membership
  has_one :profile, :dependent => :nullify

  has_many :user_talents

  has_many :notifications

  has_many :blogs, :through => :profiles

  has_many :blog_comments
  has_many :project_flaggings
  has_many :flagged_projects, :through => :project_flaggings, :source => :project
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :email, :terms_of_service
  attr_protected :is_admin, :can_send_messages
  attr_immutable :id

  validates_confirmation_of :password, :if => :password_required?
  validates_presence_of :login
  validates_presence_of :password, :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?
  validates_length_of :password_confirmation, :if => :password_required?,:within => 4..40
  validates_length_of :password, :within => 4..40, :if => :password_required?
  validates_length_of :login, :within => 3..17
  validates_uniqueness_of :login, :case_sensitive => false
  validates_format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :create, :message=>"Invalid email address."
  
  before_save :encrypt_password
  validates_less_reverse_captcha

  has_many :owned_public_projects, :class_name => "Project", :foreign_key => "owner_id", 
    :conditions=>"symbol IS NOT NULL and is_deleted = 0 and (project_payment_status is null or project_payment_status != 'Finished Payment')", 
    :order => "created_at"
  
  has_many :owned_public_funded_projects, :class_name => "Project", :foreign_key => "owner_id",
    :conditions=>"symbol IS NOT NULL and is_deleted = 0 and project_payment_status = 'Finished Payment'",
    :order => "created_at"

  has_many :owned_projects, :class_name => "Project", :foreign_key => "owner_id"

  has_many :project_subscriptions, :dependent => :destroy

  has_many :non_funded_project_subscriptions, :include => "project", 
    :class_name => "ProjectSubscription",
    :conditions => "projects.project_payment_status is null or project_payment_status != 'Finished Payment'"

  has_many :subscribed_projects, :through => :project_subscriptions, :source=> :project,
    :conditions=>'symbol IS NOT NULL and is_deleted = 0', :order => "project_subscriptions.created_at",
    :group => "projects.id"
  
  has_many :subscribed_funded_projects, :through => :project_subscriptions, :source=> :project,
    :conditions=>"symbol IS NOT NULL and is_deleted = 0 and project_payment_status = 'Finished Payment'",
    :order => "project_subscriptions.created_at", :group => "projects.id"

  has_many :subscribed_non_funded_projects, :through => :project_subscriptions, :source=> :project,
    :conditions=>"symbol IS NOT NULL and is_deleted = 0 and (project_payment_status is null or project_payment_status != 'Finished Payment')",
    :order => "project_subscriptions.created_at", :group => "projects.id"

  has_many :subscription_payments

  has_many :pmf_share_buyouts

  has_many :project_comments
  has_many :project_followings
  has_many :followed_projects, :through => :project_followings, :source => :project

  def before_create
    p = Profile.find_by_email @email
    return true if p.blank?

    errors.add(:email, 'address has already been taken.') and return false unless p.user.blank?
  end
  
  def after_create
    #make activation code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    save
    
    p = Profile.find_or_create_by_email @email
    raise 'User found when should be nil' unless p.user.blank?
    p.is_active=true
    p.user_id = id
    p.save
  end
  
  def after_destroy
    profile.update_attributes :is_active=>false
  end

  def login
    #special case for pmf_fund
    #special case for pmf_fund
    if id == PMF_FUND_ACCOUNT_ID
      return "PMF Fund"
    end

    super
  end

  def f
    profile.f
  end

  def can_mail? user
    can_send_messages? && profile.is_active?
  end

  # Authenticates a user by their login name and unencrypted password.
  # Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    return nil unless u
    u = (u && u.authenticated?(password) ? u : nil)
    
    return nil if !u
    
    raise Exceptions::UserNotActivated unless u.activated?
    u
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_me
    self.remember_token_expires_at = 10.years.from_now
    self.remember_token = UUID.random_create.to_s + '-' + UUID.random_create.to_s if self.remember_token.nil?
    save false
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  def forgot_password
    @forgot = true
    self.password = UUID.random_create.to_s[0,8]
    self.password_confirmation = password
    encrypt_password
    save!
    self.password
  end
  
  def change_password(current_password, new_password, confirm_password)
    sp = User.encrypt(current_password, self.salt)
    errors.add( :password, "The password you supplied is not the correct password.") and
      return false unless sp == self.crypted_password
    errors.add( :password, "The new password does not match the confirmation password.") and
      return false unless new_password == confirm_password
    errors.add( :password, "The new password may not be blank.") and
      return false if new_password.blank?
    
    self.password = new_password
    self.password_confirmation = confirm_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
    self.crypted_password = encrypt(new_password)
    save
  end

  def user_talents_not_applied_for
    @talent_types_map = UserTalent.talent_types_map

    #put the keys of the current users talents into an array
    @current_talent_keys = []

    user_talents.each do |talent|
      @key = @talent_types_map.invert[talent.talent_type]
      @current_talent_keys << @key.to_i
    end

    #now collect the ones that this user has not yet applied for
    @talents = {}

    @talent_types_map.each do |key, value|
      if !@current_talent_keys.include?(key)
        @talents[key] = value.humanize.titleize
      end
    end

    @talents
  end

  #load talent rating history for a talent rating
  def talent_rating talent_rating_id
    TalentRatingHistory.find_by_user_id_and_talent_rating_id(id, talent_rating_id, :order => "created_at DESC", :limit => "1")
  end

  def can_talent_rate talent_rating_id
    @tr = talent_rating talent_rating_id
    !@tr || @tr.created_at < Time.now.beginning_of_day
  end

  #takes the users current membership and applies the limits of that
  #membership to their account
  def apply_membership_limits
    #firstly, delete the latest projects over the listing limit
    @user_projects = owned_public_projects
    @num_projects_delete = @user_projects.length - membership.membership_type.max_projects_listed

    if @num_projects_delete > 0
      @user_projects_delete_array = @user_projects.to_a.reverse[0..@num_projects_delete - 1]

      for @project in @user_projects_delete_array do
        @project.delete
      end
    end

    #now delete the per project shares outstanding
    delete_subscriptions_in_projects_with_shares_over(membership.membership_type.pc_limit)

    #now delete the shares the user has in projects over total amount of
    #projects allowed to have shares in
    delete_subscriptions_in_projects_over_total_allowed(membership.membership_type.pc_project_limit)

    #now update all the projects to the new cap budget
    @funding_limit = membership.membership_type.funding_limit_per_project

    for @project in owned_public_projects do
      if @project.capital_required > @funding_limit
        @project.capital_required = @funding_limit
        @project.save!
      end
    end

    #now update all the projects to the new minimum cap budget
    @min_funding_limit = membership.membership_type.min_funding_limit_per_project

    for @project in owned_public_projects do
      if @project.capital_required < @min_funding_limit
        @project.capital_required = @min_funding_limit
        @project.save!
      end
    end

  end

  #applies memebership limits to all users accounts
  #called from admin when a membership type is updated
  def self.apply_all_membership_limits
    @all_users = User.find(:all)

    for @user in @all_users do
      @user.apply_membership_limits
    end
  end

  #get all projects belonging to a user and
  #return them as select opts for a dropdown
  def project_select_opts
    @project_select_opts = [["Choose a project...", -1], ["None", -1]]

    owned_public_projects.each do |project|
      @project_select_opts << [project.title, project.id]
    end

    @project_select_opts
  end

  ##this function returns the projects the user has shares in
  #in which the amount of shares they have in each exceeds cap
  def projects_with_shares_over(cap)
    @count = 0

    for project in subscribed_non_funded_projects do
      @project_subscriptions = ProjectSubscription.load_subscriptions self, project
      @project_subscription_amount = ProjectSubscription.calculate_amount @project_subscriptions

      if @project_subscription_amount > cap
        @count += 1
      end
    end

    @count
  end

  #this function deletes and reduces shares over cap per project
  def delete_subscriptions_in_projects_with_shares_over(cap)
    for project in subscribed_non_funded_projects do
      @project_subscriptions = ProjectSubscription.load_subscriptions self, project
      @project_subscription_amount = ProjectSubscription.calculate_amount @project_subscriptions

      if @project_subscription_amount > cap
        @cancel_amount = @project_subscription_amount - cap
        ProjectSubscription.cancel_shares_for_project(@project_subscriptions, @cancel_amount)
        project.update_funding_and_estimates
      end
    end
  end

  #this function deletes shares over cap projects for a user
  #the deleted subscriptions are the most recent first subscription
  def delete_subscriptions_in_projects_over_total_allowed(cap)
    @subscribed_projects = subscribed_non_funded_projects.to_a

    return if @subscribed_projects.length < cap

    @projects_for_subscription_delete = @subscribed_projects[cap..@subscribed_projects.length - 1]

    @projects_for_subscription_delete.each do |project|
      @project_subscriptions = ProjectSubscription.load_subscriptions self, project

      @project_subscriptions.each do |ps|
        ps.destroy
      end

      project.update_funding_and_estimates
    end
  end

  def projects_exceeding_budget_limit(cap)
    @count = 0

    for project in owned_public_projects do
      if !project.in_payment_phases? && project.capital_required > cap
        @count = @count + 1
      end

    end

    @count
  end

  def projects_under_budget_limit(cap)
    @count = 0

    for project in owned_public_projects do
      if !project.in_payment_phases? && project.capital_required < cap
        @count = @count + 1
      end

    end

    @count
  end

  def number_projects_subscribed_to
    @num = self.subscribed_projects.size > 0 ? self.subscribed_projects.uniq.size : 0
    @num
  end

  def number_non_funded_projects_subscribed_to
    @num = self.subscribed_non_funded_projects.size > 0 ? self.subscribed_non_funded_projects.uniq.size : 0
    @num
  end

  def current_subscription_payment project
    subscription_payments.find(:first, :conditions => "project_id = #{project.id} and (status = 'Open' or status = 'Pending')")
  end

  def completed_subscription_payments project
    subscription_payments.find(:all, :conditions => "project_id = #{project.id} and status = 'Paid'")
  end

  def failed_subscription_payments project
    subscription_payments.find(:all, :conditions => "project_id = #{project.id} and status = 'Defaulted'")
  end

  def completed_subscription_payment_amount project
    @sum = 0

    completed_subscription_payments(project).each do |cp|
      @sum += cp.share_amount
    end

    @sum
  end

  def failed_subscription_payment_amount project
    @sum = 0

    failed_subscription_payments(project).each do |cp|
      @sum += cp.share_amount
    end

    @sum
  end

  def completed_subscription_payment_dollar_amount project
    completed_subscription_payment_amount(project) * project.ipo_price
  end

  def failed_subscription_payment_dollar_amount project
    failed_subscription_payment_amount(project) * project.ipo_price
  end

  def following? project
    followed_projects.include? project
  end

  def flagged_project? project
    flagged_projects.include? project
  end

  def has_talent? talent_type_id
    return !talent(talent_type_id).nil?
  end

  def talent talent_type_id
    user_talents.find_by_talent_type(UserTalent.talent_types_map[talent_type_id])
  end

  def update_warn_points
    @unpaid_payments = SubscriptionPayment.find(:all, :conditions => "user_id = #{id} and status = 'Defaulted'", :group => "project_id")
    self.warn_points = @unpaid_payments.size
    save
  end

  def subscribed_projects_awaiting_payment
    Project.find_by_sql("select projects.* from projects where id in
    (select project_id from subscription_payments where (status is null or (status != 'Pending' and status != 'Paid'
    and status != 'Defaulted') and user_id = #{id}) group by project_id)")
  end

  # Activates the user in the database.
  def activate
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save
  end

  def activated?
    activation_code.nil?
  end

  protected

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if
    new_record? || @forgot
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
end
