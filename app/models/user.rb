# == Schema Information
# Schema version: 20100528091908
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
#


require 'digest/sha1'
require 'mime/types'

class User < ActiveRecord::Base
  has_one :membership, :dependent => :destroy
  has_one :membership_type, :through => :membership
  has_one :profile, :dependent => :nullify

  has_many :blog_comments
  
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
  
  has_many :owned_public_projects, :class_name => "Project", :foreign_key => "owner_id", :conditions=>'rated_at IS NOT NULL and is_deleted = 0'
  has_many :owned_projects, :class_name => "Project", :foreign_key => "owner_id"
  has_many :project_subscriptions, :dependent => :destroy
  has_many :subscribed_projects, :through => :project_subscriptions, :source=> :project, :conditions=>'rated_at IS NOT NULL and is_deleted = 0'

  has_one :project_comment

  def before_create
    p = Profile.find_by_email @email
    return true if p.blank?
    errors.add(:email, 'address has already been taken.') and return false unless p.user.blank?
  end
  
  def after_create
    p = Profile.find_or_create_by_email @email
    raise 'User found when should be nil' unless p.user.blank?
    p.is_active=true
    p.user_id = id
    p.save
    AccountMailer.deliver_signup self.reload
  end
  
  def after_destroy
    profile.update_attributes :is_active=>false
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
    u && u.authenticated?(password) ? u : nil
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

  #this function returns the projects the user has shares in
  #in which the amount of shares they have in each exceeds cap
  def projects_with_shares_over(cap)
    @count = 0

    for sub in project_subscriptions do
      if sub.amount > cap
        @count = @count + 1
      end
      
    end

    @count
  end

  def projects_exceeding_budget_limit(cap)
    @count = 0

    for project in owned_projects do
      if project.capital_required > cap
        @count = @count + 1
      end

    end

    @count
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
