# == Schema Information
# Schema version: 20101207123403
#
# Table name: project_change_info_one_days
#
#  id           :integer(4)    not null, primary key
#  share_amount :integer(4)    default(0)
#  share_change :integer(4)    default(0)
#  project_id   :integer(4)    
#  created_at   :datetime      
#  updated_at   :datetime      
#

class ProjectChangeInfoOneDay < ActiveRecord::Base

  belongs_to :project
  
  def self.top_five_change_for_user user
    find(:all, :include => :project, :conditions => "projects.owner_id = #{user.id}
      and project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "abs(project_change_info_one_days.share_change) desc", :limit => 5)
  end

  def self.top_five_change_for_site
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "project_change_info_one_days.share_change desc", :limit => 5)
  end

  def self.bottom_five_change_for_site
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "project_change_info_one_days.share_change", :limit => 5)
  end

  def self.top_ten_movers
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "abs(project_change_info_one_days.share_change) desc", :limit => 10)
  end

  def self.generate_daily_change
    puts "Generating Daily Change Info For Projects"

    #check that we have not already generated todays change
    if find(:first, :conditions => "created_at > '#{Time.now.midnight.to_s(:db)}'")
      puts "Daily Change Already Generated for #{Time.now.midnight}"
      return
    end

    @all_projects = Project.find(:all)

    @all_projects.each do |project|
      @previous_day_change_info_obj = find(:first, :conditions => "project_id = #{project.id}
          and created_at > '#{1.day.ago.midnight.to_s(:db)}'
          and created_at < '#{Time.now.midnight.to_s(:db)}'")

      @today_share_amount = project.subscription_amount

      if @previous_day_change_info_obj
        @yesterday_share_amount = @previous_day_change_info_obj.share_amount
      else
        @yesterday_share_amount = @today_share_amount
      end

      @change_amount = @today_share_amount - @yesterday_share_amount

      #create a today entry for this project
      ProjectChangeInfoOneDay.create(:project => project, :share_amount => @today_share_amount, :share_change => @change_amount)
    end

  end
end
