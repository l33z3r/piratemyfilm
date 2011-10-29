ActionController::Routing::Routes.draw do |map|
  map.resources :blogs,
    :collection => {:all_member_blogs => :get, :my_member_blogs => :get, 
    :my_project_blogs => :get, :admin => :get, :mkc => :get,
    :follow_mkc_blogs => :post, :follow_admin_blogs => :post,
    :my_mentions => :get
    }

  map.resources :project_comments

  map.resources :user_talents, :only => [:index, :create, :destroy]

  map.namespace :admin do |a|
    a.resources :users, :collection => {:search => :post}
  end

  map.resources :projects,
    :member=>{:delete_icon=>:post, :invite_friends => :get, :send_friends_invite => :post, 
    :flag => :post, :player => :get, :add_talent => :post, :remove_talent => :post},
    :collection=>{:search=>:get} do | project |
    project.resources :project_subscriptions, :collection => {:cancel => :delete}
    project.resources :project_followings, :collection => {:unfollow => :delete}, :only => [:create]
    project.resources :project_comments
  end

  map.project_widgets "project_widgets", :controller => "project_widgets", :action => "index"
  
  map.latest_comments "latest_comments", :controller => "project_comments", :action => "latest"

  map.resources :profiles, 
    :member=>{:delete_icon=>:post, :friend_list => :get}, 
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
    accounts.activate "/activate", :action => 'activate'
  end

  map.home "home", :controller => "home", :action => "index"
  map.search "home/search", :controller => "home", :action => "search", :conditions => {:method => "post"}
  
  map.login_vanity '/:userlogin', :controller => "profiles", :action => "show"

  map.connect ':controller/:action/:id'

  map.root :controller => "home", :action => "index"
  
  map.static '/pages/:action', :controller=>'static'

  map.connect '*path', :controller => 'home', :action => 'fourohfour'

end
