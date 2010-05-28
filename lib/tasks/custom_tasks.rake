task :update_max_blog=> :environment do
  Blog.update_max_blog
end

task :clear_cache => :environment do
  ActionController::Base.cache_store.clear
end