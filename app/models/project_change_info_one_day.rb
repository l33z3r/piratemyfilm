class ProjectChangeInfoOneDay < ActiveRecord::Base

  belongs_to :project
  
  def self.top_five_change_for_user user
    find(:all, :include => :project, :conditions => "projects.owner_id = #{user.id}
      and project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "abs(project_change_info_one_days.share_change) desc", :limit => 5)
  end

  def self.top_five_change_for_site
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "projects.daily_percent_move desc, project_change_info_one_days.share_change desc, projects.id", :limit => 5)
  end

  def self.bottom_five_change_for_site
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "projects.daily_percent_move, project_change_info_one_days.share_change, projects.id", :limit => 5)
  end

  def self.top_ten_movers
    find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.is_deleted = 0", :order => "abs(project_change_info_one_days.share_change) desc, projects.id", :limit => 10)
  end

  def self.today_volume_for_genre genre
    @changes = find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and projects.genre_id = #{genre.id}", :order => "abs(project_change_info_one_days.share_change) desc, projects.id", :limit => 10)

    @changes.sum(&:share_change)
  end

  def self.total_today_volume
    @changes = find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'",
      :order => "abs(project_change_info_one_days.share_change) desc, projects.id", :limit => 10)

    @sum = 0

    @changes.each do |change|
      @sum += change.share_change.abs
    end

    @sum
  end

  def self.total_today_ups
    @changes = find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and share_change > 0", :order => "abs(project_change_info_one_days.share_change) desc, projects.id", :limit => 10)

    @changes.sum(&:share_change)
  end

  def self.total_today_downs
    @changes = find(:all, :include => :project, :conditions => "project_change_info_one_days.created_at > '#{Time.now.midnight.to_s(:db)}'
      and share_change < 0", :order => "abs(project_change_info_one_days.share_change) desc, projects.id", :limit => 10)

    @changes.sum(&:share_change)
  end

  def self.generate_daily_change
    puts "Generating Daily Change Info For Projects"

    #check that we have not already generated todays change
    if find(:first, :conditions => "created_at > '#{Time.now.midnight.to_s(:db)}'")
      puts "Daily Change Already Generated for #{Time.now.midnight}"
      return
    end

    @all_projects = Project.find_all_public

    @all_projects.each do |project|
      @previous_day_change_info_obj = find(:first, :conditions => "project_id = #{project.id}
          and created_at > '#{1.day.ago.midnight.to_s(:db)}'
          and created_at < '#{Time.now.midnight.to_s(:db)}'")

      @today_share_amount = project.subscription_amount

      if @previous_day_change_info_obj
        @yesterday_share_amount = @previous_day_change_info_obj.share_amount
      else
        @yesterday_share_amount = 0
      end

      @change_amount = @today_share_amount - @yesterday_share_amount

      #create a today entry for this project
      @change_info = ProjectChangeInfoOneDay.create(:project => project, :share_amount => @today_share_amount, :share_change => @change_amount)

      project.daily_percent_move = @change_info.percent_move
      project.save
      
    end

  end

  def percent_move
    @last_night_share_amount = share_amount - share_change
    
    if @last_night_share_amount == 0
      #if we have two consecutive days of 0, then the % is zero,
      #else the change is 100%
      if share_change == 0 
        @change_percent = 0
      else
        @change_percent = 100
      end
    else
      @abs_change_percent = ((share_change.to_f.abs/@last_night_share_amount) * 100).ceil
      
      #multiplying by this var will convert back to neg/pos
      if share_change == 0
        @neg_pos = 1
      else
        @neg_pos = share_change/share_change
      end
      
      #now convert back to neg/pos
      @change_percent = @abs_change_percent * @neg_pos
    end
    
    @change_percent
  end
end


# == Schema Information
#
# Table name: project_change_info_one_days
#
#  id           :integer(4)      not null, primary key
#  share_amount :integer(4)      default(0)
#  share_change :integer(4)      default(0)
#  project_id   :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

