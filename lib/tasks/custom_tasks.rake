task :update_max_blog=> :environment do
  Blog.update_max_blog
end

task :clear_cache => :environment do
  ActionController::Base.cache_store.clear
end

desc "Updates the ferret index for the application."
task :ferret_index => [ :environment ] do | t |
  Project.rebuild_index
  puts "Completed Index Rebuild of Project model"
  Profile.rebuild_index
  puts "Completed Index Rebuild of Profile model"
end