class ProjectChangeInfoOneDay < ActiveRecord::Base

  def self.top_five_change_for_user user
    return
    @project_ids = []

    user.owned_public_projects.each do |project|
      @project_ids << project.id
    end

    return [] if @project_ids.size == 0

    @sql = 'select profiles.* from profiles join users on profiles.user_id = users.id
        order by users.login'

    find_by_sql(@sql)
  end
end
