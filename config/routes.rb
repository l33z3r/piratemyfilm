ActionController::Routing::Routes.draw do |map|
  map.resources :blogs, :only => [:show, :homepage]

  map.connect "admin", :controller => "blogs", :action => "admin"
  map.connect "producer", :controller => "blogs", :action => "producer"
  map.connect "mkc", :controller => "blogs", :action => "mkc"

  map.resources :project_comments

  map.namespace :admin do |a|
    a.resources :users, :collection => {:search => :post}
  end

  map.resources :profiles, 
    :member=>{:delete_icon=>:post}, :collection=>{:search=>:get}, 
    :has_many=>[:friends, :blogs, :photos, :comments, :feed_items, :messages]

  map.resources :messages, :collection => {:sent => :get}
  
  map.resources :forums, :collection => {:update_positions => :post} do |forum|
    forum.resources :topics, :controller => :forum_topics do |topic|
      topic.resources :posts, :controller => :forum_posts
    end
  end

  map.with_options(:controller => 'accounts') do |accounts|
    accounts.login   "/login",   :action => 'login'
    accounts.logout  "/logout",  :action => 'logout'
    accounts.signup  "/signup",  :action => 'signup'
  end
  
  map.with_options(:controller => 'home') do |home|
    home.home '/', :action => 'index'
    home.contact '/contact', :action => 'contact'
  end

  map.resources :projects, 
    :member=>{:delete_icon=>:post}, :collection=>{:search=>:get} do | project |
    project.resources :project_subscriptions, :member => {:destroy=>:delete}
  end

  map.connect ':controller/:action/:id'

  map.root :controller => "home", :action => "index"
  
  map.static '/pages/:action', :controller=>'static'

  map.connect '*path', :controller => 'home', :action => 'fourohfour'

end
