ActionController::Routing::Routes.draw do |map|
  map.resources :blogs,
    :collection => {:admin => :get, :producer => :get, :mkc => :get}

  map.resources :project_comments

  map.resources :user_talents, :only => [:index, :create, :destroy]

  map.namespace :admin do |a|
    a.resources :users, :collection => {:search => :post}
  end

  map.resources :projects,
    :member=>{:delete_icon=>:post, :invite_friends => :get, :send_friends_invite => :post, :flag => :post},
    :collection=>{:search=>:get} do | project |
    project.resources :project_subscriptions, :collection => {:cancel => :delete}
    project.resources :project_followings, :collection => {:unfollow => :delete}, :only => [:create]
    project.resources :project_comments
  end

  map.latest_comments "latest_comments", :controller => "project_comments", :action => "latest"

  map.resources :profiles, 
    :member=>{:delete_icon=>:post, :portfolio=>:get, :friend_list => :get}, 
    :collection=>{:search=>:get, :portfolio_awaiting_payment => :get},
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
  
  map.connect ':controller/:action/:id'

  map.home "home", :controller => "home", :action => "index"
  
  map.root :controller => "home", :action => "index"
  
  map.static '/pages/:action', :controller=>'static'

  map.connect '*path', :controller => 'home', :action => 'fourohfour'

end
