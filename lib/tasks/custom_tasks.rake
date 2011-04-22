desc "Update the Max blog being pulled from maxkeiser.com"
task :update_max_blog => :environment do
  Blog.update_max_blog
end

desc "Update the daily share change in each project"
task :generate_project_change_info => :environment do
  ProjectChangeInfoOneDay.generate_daily_change
end

desc "Clear the whole memcahce"
task :clear_cache => :environment do
  ActionController::Base.cache_store.clear
end

desc "Update Ferret index for the application."
task :ferret_index => :environment do
  Project.rebuild_index
  puts "Completed Index Rebuild of Project model"
  Profile.rebuild_index
  puts "Completed Index Rebuild of Profile model"
end

desc "Clear expired sessions"
task :clear_expired_sessions => :environment do
  sql = 'DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL 3 DAYS);'
  ActiveRecord::Base.connection.execute(sql)

  #defrag the table
  sql = 'OPTIMIZE TABLE sessions;'
  ActiveRecord::Base.connection.execute(sql)
end
