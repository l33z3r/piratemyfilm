# == Schema Information
# Schema version: 20101207123403
#
# Table name: project_comments
#
#  id         :integer(4)    not null, primary key
#  body       :text          
#  user_id    :integer(4)    
#  project_id :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class ProjectComment < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  def self.latest
    find(:all, :include => :project, :conditions => "projects.is_deleted = false and projects.symbol is not null",
      :order => "project_comments.created_at desc")
  end

  def self.latest_for_user_followings user

    @project_ids = []

    user.followed_projects.each do |project|
      @project_ids << project.id
    end

    return [] if @project_ids.size == 0
    
    find(:all, :include => :project, :conditions => "projects.is_deleted = false and projects.symbol is not null and projects.id in (#{@project_ids.join(",")})",
      :order => "project_comments.created_at desc")
  end

end
