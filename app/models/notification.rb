class Notification < ActiveRecord::Base

  belongs_to :user

  @@NOTIFICATION_TYPES_MAP = {
    1 => "My Project Gets Green Light", 2 => "Any Project Gets Green Light",
    3 => "New Project Listed", 4 => "My Project Is Fully Funded",
    5 => "Any Project is Fully Funded", 6 => "My Project Is 90% Funded",
    7 => "Any Project is 90% Funded", 8 => "PMF Rating Changed On My Project",
    9 => "PMF Rating Changed On Any Project", 10 => "My Project Gets Yellow Light",
    11 => "Any Project Gets Yellow Light"
  }

  def self.all_types
    @@NOTIFICATION_TYPES_MAP.sort
  end

  def description
    return @@NOTIFICATION_TYPES_MAP[notification_type_id]
  end

  def self.deliver_yellow_light_notification project
    #deliver the personal ones first
    @owner_email_address = nil

    if project.owner.profile.receiving_notification_type(10)
      @owner_email_address = project.owner.profile.email

      NotificationsMailer.deliver_my_yellow_light project, @owner_email_address
    end

    #deliver to others
    @email_addresses = Notification.find_all_by_notification_type_id(11).collect do |notification|
      notification.user.profile.email
    end

    #remove the owners email address
    @email_addresses.delete(@owner_email_address)

    #join with all the share holders email addresses
    @share_holders_email_addresses = project.subscribers.collect do |user|
      user.profile.email
    end
    
    @email_addresses = @email_addresses | @share_holders_email_addresses
    
    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_yellow_light project, email_address
      rescue Exception
      end
    end
  end
  
  def self.deliver_green_light_notification project
    #deliver the personal ones first
    @owner_email_address = nil

    if project.owner.profile.receiving_notification_type(1)
      @owner_email_address = project.owner.profile.email

      NotificationsMailer.deliver_my_green_light project, @owner_email_address
    end

    #deliver to others
    @email_addresses = Notification.find_all_by_notification_type_id(2).collect do |notification|
      notification.user.profile.email
    end

    #remove the owners email address
    @email_addresses.delete(@owner_email_address)

    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_green_light project, email_address
      rescue Exception
      end
    end
  end

  def self.deliver_project_listed_notification project
    @email_addresses = Notification.find_all_by_notification_type_id(3).collect do |notification|
      notification.user.profile.email
    end

    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_project_listed project, email_address
      rescue Exception
      end
    end
  end

  def self.deliver_fully_funded_notification project
    #deliver the personal ones first
    @owner_email_address = nil

    if project.owner.profile.receiving_notification_type(4)
      @owner_email_address = project.owner.profile.email

      NotificationsMailer.deliver_my_project_fully_funded project, @owner_email_address
    end

    #deliver to others
    @email_addresses = Notification.find_all_by_notification_type_id(5).collect do |notification|
      notification.user.profile.email
    end

    #remove the owners email address
    @email_addresses.delete(@owner_email_address)

    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_project_fully_funded project, email_address
      rescue Exception
      end
    end
  end

  def self.deliver_90_percent_funded_notification project
    #deliver the personal ones first
    @owner_email_address = nil

    if project.owner.profile.receiving_notification_type(6)
      @owner_email_address = project.owner.profile.email

      NotificationsMailer.deliver_my_project_90_percent_funded project, @owner_email_address
    end

    #deliver to others
    @email_addresses = Notification.find_all_by_notification_type_id(7).collect do |notification|
      notification.user.profile.email
    end

    #remove the owners email address
    @email_addresses.delete(@owner_email_address)

    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_project_90_percent_funded project, email_address
      rescue Exception
      end
    end
  end

  def self.deliver_pmf_rating_changed_notification project, old_rating_symbol, new_rating_symbol
     #deliver the personal ones first
    @owner_email_address = nil

    if project.owner.profile.receiving_notification_type(8)
      @owner_email_address = project.owner.profile.email

      NotificationsMailer.deliver_my_pmf_rating_changed project, old_rating_symbol, new_rating_symbol, @owner_email_address
    end

    #deliver to others
    @email_addresses = Notification.find_all_by_notification_type_id(9).collect do |notification|
      notification.user.profile.email
    end

    #remove the owners email address
    @email_addresses.delete(@owner_email_address)

    @email_addresses.each do |email_address|
      begin
        NotificationsMailer.deliver_pmf_rating_changed project, old_rating_symbol, new_rating_symbol, email_address
      rescue Exception
      end
    end
  end

end


# == Schema Information
#
# Table name: notifications
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  notification_type_id :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#

