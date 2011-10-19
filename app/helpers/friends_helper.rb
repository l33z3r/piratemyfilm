module FriendsHelper
  def get_friend_link profile, target
    return wrap_get_friend_link(link_to('Log In To Follow This User', login_path)) if profile.blank?
    return '' unless profile && target

    dom_id = profile.dom_id(target.dom_id + '_friendship_')
    
    return wrap_get_friend_link('') if profile == target
    #return wrap_get_friend_link(link_to_remote( 'Stop Being Friends', :url => profile_friend_path(profile, target), :method => :delete), dom_id) if profile.friend_of? target
    return wrap_get_friend_link(link_to_remote( 'Stop Following', :url => profile_friend_path(profile, target), :method => :delete), dom_id) if profile.following? target
    #return wrap_get_friend_link(link_to_remote( 'Be Friends', :url => profile_friends_path(target), :method => :post), dom_id) if profile.followed_by? target
    wrap_get_friend_link(link_to_remote( 'Start Following', :url => profile_friends_path(target), :method => :post), dom_id)
  end

  def follow_member_button_small target_member
    return if @u and target_member == @u.profile
    
    if @u and (@u.profile.following? target_member or @u.profile.friend_of? target_member)
      content_tag :div, :class => "button_small left" do
        link_to "Unfollow", profile_friend_path(@u.profile, target_member), :method => :delete
      end
    else
      content_tag :div, :class => "button_small left" do
        link_to "Follow", profile_friends_path(target_member), :method => "post"
      end
    end
  end
  
  def follow_member_button target_member
    return if @u and target_member == @u.profile
    
    if @u and (@u.profile.following? target_member or @u.profile.friend_of? target_member)
      content_tag :div, :class => "button left" do
        link_to "Un-Follow", profile_friend_path(@u.profile, target_member), :method => :delete
      end
    else
      content_tag :div, :class => "button left" do
        link_to "Follow", profile_friends_path(target_member), :method => "post"
      end
    end
  end
  
  protected
  
  def wrap_get_friend_link str, dom_id = ''
    content_tag :span, str, :id=>dom_id, :class=>'friendship_description'
  end
end