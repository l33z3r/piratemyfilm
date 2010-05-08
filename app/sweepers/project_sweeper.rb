class ProjectSweeper < ActionController::Caching::Sweeper

  observe Project, ProjectSubscription

  def after_create(project)
    expire_cache_for(project)
  end

  def after_update(project)
    expire_cache_for(project)
  end

  def after_destroy(project)
    expire_cache_for(project)
  end

  private
  
  def expire_cache_for(record)
    Rails.cache.delete('controller/hp_projects')
  end
end