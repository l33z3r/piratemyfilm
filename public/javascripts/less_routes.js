function less_json_eval(json){return eval('(' +  json + ')')}  

function less_get_params(obj){
   
  if (jQuery) { return obj }
  if (obj == null) {return '';}
  var s = [];
  for (prop in obj){
    s.push(prop + "=" + obj[prop]);
  }
  return s.join('&') + '';
}

function less_merge_objects(a, b){
   
  if (b == null) {return a;}
  z = new Object;
  for (prop in a){z[prop] = a[prop]}
  for (prop in b){z[prop] = b[prop]}
  return z;
}

function less_ajax(url, verb, params, options){
   
  if (verb == undefined) {verb = 'get';}
  var res;
  if (jQuery){
    v = verb.toLowerCase() == 'get' ? 'GET' : 'POST'
    if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = less_get_params(params);}
    else{p = less_get_params(less_merge_objects({'_method': verb.toLowerCase()}, params))} 
     
     
    res = jQuery.ajax(less_merge_objects({async:false, url: url, type: v, data: p}, options)).responseText;
  } else {  
    new Ajax.Request(url, less_merge_objects({asynchronous: false, method: verb, parameters: less_get_params(params), onComplete: function(r){res = r.responseText;}}, options));
  }
  if (url.indexOf('.json') == url.length-5){ return less_json_eval(res);}
  else {return res;}
}
function less_ajaxx(url, verb, params, options){
   
  if (verb == undefined) {verb = 'get';}
  if (jQuery){
    v = verb.toLowerCase() == 'get' ? 'GET' : 'POST'
    if (verb.toLowerCase() == 'get' || verb.toLowerCase() == 'post'){p = less_get_params(params);}
    else{p = less_get_params(less_merge_objects({'_method': verb.toLowerCase()}, params))} 
     
     
    jQuery.ajax(less_merge_objects({ url: url, type: v, data: p, complete: function(r){eval(r.responseText)}}, options));
  } else {  
    new Ajax.Request(url, less_merge_objects({method: verb, parameters: less_get_params(params), onComplete: function(r){eval(r.responseText);}}, options));
  }
}
function follow_mkc_blogs_blogs_path(verb){ return '/blogs/follow_mkc_blogs';}
function follow_mkc_blogs_blogs_ajax(verb, params, options){ return less_ajax('/blogs/follow_mkc_blogs', verb, params, options);}
function follow_mkc_blogs_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/follow_mkc_blogs', verb, params, options);}
function formatted_follow_mkc_blogs_blogs_path(format, verb){ return '/blogs/follow_mkc_blogs.' + format + '';}
function formatted_follow_mkc_blogs_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/follow_mkc_blogs.' + format + '', verb, params, options);}
function formatted_follow_mkc_blogs_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/follow_mkc_blogs.' + format + '', verb, params, options);}
function follow_admin_blogs_blogs_path(verb){ return '/blogs/follow_admin_blogs';}
function follow_admin_blogs_blogs_ajax(verb, params, options){ return less_ajax('/blogs/follow_admin_blogs', verb, params, options);}
function follow_admin_blogs_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/follow_admin_blogs', verb, params, options);}
function formatted_follow_admin_blogs_blogs_path(format, verb){ return '/blogs/follow_admin_blogs.' + format + '';}
function formatted_follow_admin_blogs_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/follow_admin_blogs.' + format + '', verb, params, options);}
function formatted_follow_admin_blogs_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/follow_admin_blogs.' + format + '', verb, params, options);}
function admin_blogs_path(verb){ return '/blogs/admin';}
function admin_blogs_ajax(verb, params, options){ return less_ajax('/blogs/admin', verb, params, options);}
function admin_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/admin', verb, params, options);}
function formatted_admin_blogs_path(format, verb){ return '/blogs/admin.' + format + '';}
function formatted_admin_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/admin.' + format + '', verb, params, options);}
function formatted_admin_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/admin.' + format + '', verb, params, options);}
function my_mentions_blogs_path(verb){ return '/blogs/my_mentions';}
function my_mentions_blogs_ajax(verb, params, options){ return less_ajax('/blogs/my_mentions', verb, params, options);}
function my_mentions_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/my_mentions', verb, params, options);}
function formatted_my_mentions_blogs_path(format, verb){ return '/blogs/my_mentions.' + format + '';}
function formatted_my_mentions_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/my_mentions.' + format + '', verb, params, options);}
function formatted_my_mentions_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/my_mentions.' + format + '', verb, params, options);}
function all_member_blogs_blogs_path(verb){ return '/blogs/all_member_blogs';}
function all_member_blogs_blogs_ajax(verb, params, options){ return less_ajax('/blogs/all_member_blogs', verb, params, options);}
function all_member_blogs_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/all_member_blogs', verb, params, options);}
function formatted_all_member_blogs_blogs_path(format, verb){ return '/blogs/all_member_blogs.' + format + '';}
function formatted_all_member_blogs_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/all_member_blogs.' + format + '', verb, params, options);}
function formatted_all_member_blogs_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/all_member_blogs.' + format + '', verb, params, options);}
function my_member_blogs_blogs_path(verb){ return '/blogs/my_member_blogs';}
function my_member_blogs_blogs_ajax(verb, params, options){ return less_ajax('/blogs/my_member_blogs', verb, params, options);}
function my_member_blogs_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/my_member_blogs', verb, params, options);}
function formatted_my_member_blogs_blogs_path(format, verb){ return '/blogs/my_member_blogs.' + format + '';}
function formatted_my_member_blogs_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/my_member_blogs.' + format + '', verb, params, options);}
function formatted_my_member_blogs_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/my_member_blogs.' + format + '', verb, params, options);}
function my_project_blogs_blogs_path(verb){ return '/blogs/my_project_blogs';}
function my_project_blogs_blogs_ajax(verb, params, options){ return less_ajax('/blogs/my_project_blogs', verb, params, options);}
function my_project_blogs_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/my_project_blogs', verb, params, options);}
function formatted_my_project_blogs_blogs_path(format, verb){ return '/blogs/my_project_blogs.' + format + '';}
function formatted_my_project_blogs_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/my_project_blogs.' + format + '', verb, params, options);}
function formatted_my_project_blogs_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/my_project_blogs.' + format + '', verb, params, options);}
function mkc_blogs_path(verb){ return '/blogs/mkc';}
function mkc_blogs_ajax(verb, params, options){ return less_ajax('/blogs/mkc', verb, params, options);}
function mkc_blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs/mkc', verb, params, options);}
function formatted_mkc_blogs_path(format, verb){ return '/blogs/mkc.' + format + '';}
function formatted_mkc_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs/mkc.' + format + '', verb, params, options);}
function formatted_mkc_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/mkc.' + format + '', verb, params, options);}
function blogs_path(verb){ return '/blogs';}
function blogs_ajax(verb, params, options){ return less_ajax('/blogs', verb, params, options);}
function blogs_ajaxx(verb, params, options){ return less_ajaxx('/blogs', verb, params, options);}
function formatted_blogs_path(format, verb){ return '/blogs.' + format + '';}
function formatted_blogs_ajax(format, verb, params, options){ return less_ajax('/blogs.' + format + '', verb, params, options);}
function formatted_blogs_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs.' + format + '', verb, params, options);}
function new_blog_path(verb){ return '/blogs/new';}
function new_blog_ajax(verb, params, options){ return less_ajax('/blogs/new', verb, params, options);}
function new_blog_ajaxx(verb, params, options){ return less_ajaxx('/blogs/new', verb, params, options);}
function formatted_new_blog_path(format, verb){ return '/blogs/new.' + format + '';}
function formatted_new_blog_ajax(format, verb, params, options){ return less_ajax('/blogs/new.' + format + '', verb, params, options);}
function formatted_new_blog_ajaxx(format, verb, params, options){ return less_ajaxx('/blogs/new.' + format + '', verb, params, options);}
function edit_blog_path(id, verb){ return '/blogs/' + id + '/edit';}
function edit_blog_ajax(id, verb, params, options){ return less_ajax('/blogs/' + id + '/edit', verb, params, options);}
function edit_blog_ajaxx(id, verb, params, options){ return less_ajaxx('/blogs/' + id + '/edit', verb, params, options);}
function formatted_edit_blog_path(id, format, verb){ return '/blogs/' + id + '/edit.' + format + '';}
function formatted_edit_blog_ajax(id, format, verb, params, options){ return less_ajax('/blogs/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_blog_ajaxx(id, format, verb, params, options){ return less_ajaxx('/blogs/' + id + '/edit.' + format + '', verb, params, options);}
function blog_path(id, verb){ return '/blogs/' + id + '';}
function blog_ajax(id, verb, params, options){ return less_ajax('/blogs/' + id + '', verb, params, options);}
function blog_ajaxx(id, verb, params, options){ return less_ajaxx('/blogs/' + id + '', verb, params, options);}
function formatted_blog_path(id, format, verb){ return '/blogs/' + id + '.' + format + '';}
function formatted_blog_ajax(id, format, verb, params, options){ return less_ajax('/blogs/' + id + '.' + format + '', verb, params, options);}
function formatted_blog_ajaxx(id, format, verb, params, options){ return less_ajaxx('/blogs/' + id + '.' + format + '', verb, params, options);}
function project_comments_path(verb){ return '/project_comments';}
function project_comments_ajax(verb, params, options){ return less_ajax('/project_comments', verb, params, options);}
function project_comments_ajaxx(verb, params, options){ return less_ajaxx('/project_comments', verb, params, options);}
function formatted_project_comments_path(format, verb){ return '/project_comments.' + format + '';}
function formatted_project_comments_ajax(format, verb, params, options){ return less_ajax('/project_comments.' + format + '', verb, params, options);}
function formatted_project_comments_ajaxx(format, verb, params, options){ return less_ajaxx('/project_comments.' + format + '', verb, params, options);}
function new_project_comment_path(verb){ return '/project_comments/new';}
function new_project_comment_ajax(verb, params, options){ return less_ajax('/project_comments/new', verb, params, options);}
function new_project_comment_ajaxx(verb, params, options){ return less_ajaxx('/project_comments/new', verb, params, options);}
function formatted_new_project_comment_path(format, verb){ return '/project_comments/new.' + format + '';}
function formatted_new_project_comment_ajax(format, verb, params, options){ return less_ajax('/project_comments/new.' + format + '', verb, params, options);}
function formatted_new_project_comment_ajaxx(format, verb, params, options){ return less_ajaxx('/project_comments/new.' + format + '', verb, params, options);}
function edit_project_comment_path(id, verb){ return '/project_comments/' + id + '/edit';}
function edit_project_comment_ajax(id, verb, params, options){ return less_ajax('/project_comments/' + id + '/edit', verb, params, options);}
function edit_project_comment_ajaxx(id, verb, params, options){ return less_ajaxx('/project_comments/' + id + '/edit', verb, params, options);}
function formatted_edit_project_comment_path(id, format, verb){ return '/project_comments/' + id + '/edit.' + format + '';}
function formatted_edit_project_comment_ajax(id, format, verb, params, options){ return less_ajax('/project_comments/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_project_comment_ajaxx(id, format, verb, params, options){ return less_ajaxx('/project_comments/' + id + '/edit.' + format + '', verb, params, options);}
function project_comment_path(id, verb){ return '/project_comments/' + id + '';}
function project_comment_ajax(id, verb, params, options){ return less_ajax('/project_comments/' + id + '', verb, params, options);}
function project_comment_ajaxx(id, verb, params, options){ return less_ajaxx('/project_comments/' + id + '', verb, params, options);}
function formatted_project_comment_path(id, format, verb){ return '/project_comments/' + id + '.' + format + '';}
function formatted_project_comment_ajax(id, format, verb, params, options){ return less_ajax('/project_comments/' + id + '.' + format + '', verb, params, options);}
function formatted_project_comment_ajaxx(id, format, verb, params, options){ return less_ajaxx('/project_comments/' + id + '.' + format + '', verb, params, options);}
function user_talents_path(verb){ return '/user_talents';}
function user_talents_ajax(verb, params, options){ return less_ajax('/user_talents', verb, params, options);}
function user_talents_ajaxx(verb, params, options){ return less_ajaxx('/user_talents', verb, params, options);}
function formatted_user_talents_path(format, verb){ return '/user_talents.' + format + '';}
function formatted_user_talents_ajax(format, verb, params, options){ return less_ajax('/user_talents.' + format + '', verb, params, options);}
function formatted_user_talents_ajaxx(format, verb, params, options){ return less_ajaxx('/user_talents.' + format + '', verb, params, options);}
function new_user_talent_path(verb){ return '/user_talents/new';}
function new_user_talent_ajax(verb, params, options){ return less_ajax('/user_talents/new', verb, params, options);}
function new_user_talent_ajaxx(verb, params, options){ return less_ajaxx('/user_talents/new', verb, params, options);}
function formatted_new_user_talent_path(format, verb){ return '/user_talents/new.' + format + '';}
function formatted_new_user_talent_ajax(format, verb, params, options){ return less_ajax('/user_talents/new.' + format + '', verb, params, options);}
function formatted_new_user_talent_ajaxx(format, verb, params, options){ return less_ajaxx('/user_talents/new.' + format + '', verb, params, options);}
function edit_user_talent_path(id, verb){ return '/user_talents/' + id + '/edit';}
function edit_user_talent_ajax(id, verb, params, options){ return less_ajax('/user_talents/' + id + '/edit', verb, params, options);}
function edit_user_talent_ajaxx(id, verb, params, options){ return less_ajaxx('/user_talents/' + id + '/edit', verb, params, options);}
function formatted_edit_user_talent_path(id, format, verb){ return '/user_talents/' + id + '/edit.' + format + '';}
function formatted_edit_user_talent_ajax(id, format, verb, params, options){ return less_ajax('/user_talents/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_user_talent_ajaxx(id, format, verb, params, options){ return less_ajaxx('/user_talents/' + id + '/edit.' + format + '', verb, params, options);}
function user_talent_path(id, verb){ return '/user_talents/' + id + '';}
function user_talent_ajax(id, verb, params, options){ return less_ajax('/user_talents/' + id + '', verb, params, options);}
function user_talent_ajaxx(id, verb, params, options){ return less_ajaxx('/user_talents/' + id + '', verb, params, options);}
function formatted_user_talent_path(id, format, verb){ return '/user_talents/' + id + '.' + format + '';}
function formatted_user_talent_ajax(id, format, verb, params, options){ return less_ajax('/user_talents/' + id + '.' + format + '', verb, params, options);}
function formatted_user_talent_ajaxx(id, format, verb, params, options){ return less_ajaxx('/user_talents/' + id + '.' + format + '', verb, params, options);}
function search_admin_users_path(verb){ return '/admin/users/search';}
function search_admin_users_ajax(verb, params, options){ return less_ajax('/admin/users/search', verb, params, options);}
function search_admin_users_ajaxx(verb, params, options){ return less_ajaxx('/admin/users/search', verb, params, options);}
function formatted_search_admin_users_path(format, verb){ return '/admin/users/search.' + format + '';}
function formatted_search_admin_users_ajax(format, verb, params, options){ return less_ajax('/admin/users/search.' + format + '', verb, params, options);}
function formatted_search_admin_users_ajaxx(format, verb, params, options){ return less_ajaxx('/admin/users/search.' + format + '', verb, params, options);}
function admin_users_path(verb){ return '/admin/users';}
function admin_users_ajax(verb, params, options){ return less_ajax('/admin/users', verb, params, options);}
function admin_users_ajaxx(verb, params, options){ return less_ajaxx('/admin/users', verb, params, options);}
function formatted_admin_users_path(format, verb){ return '/admin/users.' + format + '';}
function formatted_admin_users_ajax(format, verb, params, options){ return less_ajax('/admin/users.' + format + '', verb, params, options);}
function formatted_admin_users_ajaxx(format, verb, params, options){ return less_ajaxx('/admin/users.' + format + '', verb, params, options);}
function new_admin_user_path(verb){ return '/admin/users/new';}
function new_admin_user_ajax(verb, params, options){ return less_ajax('/admin/users/new', verb, params, options);}
function new_admin_user_ajaxx(verb, params, options){ return less_ajaxx('/admin/users/new', verb, params, options);}
function formatted_new_admin_user_path(format, verb){ return '/admin/users/new.' + format + '';}
function formatted_new_admin_user_ajax(format, verb, params, options){ return less_ajax('/admin/users/new.' + format + '', verb, params, options);}
function formatted_new_admin_user_ajaxx(format, verb, params, options){ return less_ajaxx('/admin/users/new.' + format + '', verb, params, options);}
function edit_admin_user_path(id, verb){ return '/admin/users/' + id + '/edit';}
function edit_admin_user_ajax(id, verb, params, options){ return less_ajax('/admin/users/' + id + '/edit', verb, params, options);}
function edit_admin_user_ajaxx(id, verb, params, options){ return less_ajaxx('/admin/users/' + id + '/edit', verb, params, options);}
function formatted_edit_admin_user_path(id, format, verb){ return '/admin/users/' + id + '/edit.' + format + '';}
function formatted_edit_admin_user_ajax(id, format, verb, params, options){ return less_ajax('/admin/users/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_admin_user_ajaxx(id, format, verb, params, options){ return less_ajaxx('/admin/users/' + id + '/edit.' + format + '', verb, params, options);}
function admin_user_path(id, verb){ return '/admin/users/' + id + '';}
function admin_user_ajax(id, verb, params, options){ return less_ajax('/admin/users/' + id + '', verb, params, options);}
function admin_user_ajaxx(id, verb, params, options){ return less_ajaxx('/admin/users/' + id + '', verb, params, options);}
function formatted_admin_user_path(id, format, verb){ return '/admin/users/' + id + '.' + format + '';}
function formatted_admin_user_ajax(id, format, verb, params, options){ return less_ajax('/admin/users/' + id + '.' + format + '', verb, params, options);}
function formatted_admin_user_ajaxx(id, format, verb, params, options){ return less_ajaxx('/admin/users/' + id + '.' + format + '', verb, params, options);}
function search_projects_path(verb){ return '/projects/search';}
function search_projects_ajax(verb, params, options){ return less_ajax('/projects/search', verb, params, options);}
function search_projects_ajaxx(verb, params, options){ return less_ajaxx('/projects/search', verb, params, options);}
function formatted_search_projects_path(format, verb){ return '/projects/search.' + format + '';}
function formatted_search_projects_ajax(format, verb, params, options){ return less_ajax('/projects/search.' + format + '', verb, params, options);}
function formatted_search_projects_ajaxx(format, verb, params, options){ return less_ajaxx('/projects/search.' + format + '', verb, params, options);}
function projects_path(verb){ return '/projects';}
function projects_ajax(verb, params, options){ return less_ajax('/projects', verb, params, options);}
function projects_ajaxx(verb, params, options){ return less_ajaxx('/projects', verb, params, options);}
function formatted_projects_path(format, verb){ return '/projects.' + format + '';}
function formatted_projects_ajax(format, verb, params, options){ return less_ajax('/projects.' + format + '', verb, params, options);}
function formatted_projects_ajaxx(format, verb, params, options){ return less_ajaxx('/projects.' + format + '', verb, params, options);}
function new_project_path(verb){ return '/projects/new';}
function new_project_ajax(verb, params, options){ return less_ajax('/projects/new', verb, params, options);}
function new_project_ajaxx(verb, params, options){ return less_ajaxx('/projects/new', verb, params, options);}
function formatted_new_project_path(format, verb){ return '/projects/new.' + format + '';}
function formatted_new_project_ajax(format, verb, params, options){ return less_ajax('/projects/new.' + format + '', verb, params, options);}
function formatted_new_project_ajaxx(format, verb, params, options){ return less_ajaxx('/projects/new.' + format + '', verb, params, options);}
function send_friends_invite_project_path(id, verb){ return '/projects/' + id + '/send_friends_invite';}
function send_friends_invite_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/send_friends_invite', verb, params, options);}
function send_friends_invite_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/send_friends_invite', verb, params, options);}
function formatted_send_friends_invite_project_path(id, format, verb){ return '/projects/' + id + '/send_friends_invite.' + format + '';}
function formatted_send_friends_invite_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/send_friends_invite.' + format + '', verb, params, options);}
function formatted_send_friends_invite_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/send_friends_invite.' + format + '', verb, params, options);}
function flag_project_path(id, verb){ return '/projects/' + id + '/flag';}
function flag_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/flag', verb, params, options);}
function flag_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/flag', verb, params, options);}
function formatted_flag_project_path(id, format, verb){ return '/projects/' + id + '/flag.' + format + '';}
function formatted_flag_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/flag.' + format + '', verb, params, options);}
function formatted_flag_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/flag.' + format + '', verb, params, options);}
function add_talent_project_path(id, verb){ return '/projects/' + id + '/add_talent';}
function add_talent_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/add_talent', verb, params, options);}
function add_talent_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/add_talent', verb, params, options);}
function formatted_add_talent_project_path(id, format, verb){ return '/projects/' + id + '/add_talent.' + format + '';}
function formatted_add_talent_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/add_talent.' + format + '', verb, params, options);}
function formatted_add_talent_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/add_talent.' + format + '', verb, params, options);}
function remove_talent_project_path(id, verb){ return '/projects/' + id + '/remove_talent';}
function remove_talent_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/remove_talent', verb, params, options);}
function remove_talent_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/remove_talent', verb, params, options);}
function formatted_remove_talent_project_path(id, format, verb){ return '/projects/' + id + '/remove_talent.' + format + '';}
function formatted_remove_talent_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/remove_talent.' + format + '', verb, params, options);}
function formatted_remove_talent_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/remove_talent.' + format + '', verb, params, options);}
function delete_icon_project_path(id, verb){ return '/projects/' + id + '/delete_icon';}
function delete_icon_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/delete_icon', verb, params, options);}
function delete_icon_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/delete_icon', verb, params, options);}
function formatted_delete_icon_project_path(id, format, verb){ return '/projects/' + id + '/delete_icon.' + format + '';}
function formatted_delete_icon_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/delete_icon.' + format + '', verb, params, options);}
function formatted_delete_icon_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/delete_icon.' + format + '', verb, params, options);}
function edit_project_path(id, verb){ return '/projects/' + id + '/edit';}
function edit_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/edit', verb, params, options);}
function edit_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/edit', verb, params, options);}
function formatted_edit_project_path(id, format, verb){ return '/projects/' + id + '/edit.' + format + '';}
function formatted_edit_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/edit.' + format + '', verb, params, options);}
function player_project_path(id, verb){ return '/projects/' + id + '/player';}
function player_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/player', verb, params, options);}
function player_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/player', verb, params, options);}
function formatted_player_project_path(id, format, verb){ return '/projects/' + id + '/player.' + format + '';}
function formatted_player_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/player.' + format + '', verb, params, options);}
function formatted_player_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/player.' + format + '', verb, params, options);}
function invite_friends_project_path(id, verb){ return '/projects/' + id + '/invite_friends';}
function invite_friends_project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '/invite_friends', verb, params, options);}
function invite_friends_project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '/invite_friends', verb, params, options);}
function formatted_invite_friends_project_path(id, format, verb){ return '/projects/' + id + '/invite_friends.' + format + '';}
function formatted_invite_friends_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '/invite_friends.' + format + '', verb, params, options);}
function formatted_invite_friends_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '/invite_friends.' + format + '', verb, params, options);}
function project_path(id, verb){ return '/projects/' + id + '';}
function project_ajax(id, verb, params, options){ return less_ajax('/projects/' + id + '', verb, params, options);}
function project_ajaxx(id, verb, params, options){ return less_ajaxx('/projects/' + id + '', verb, params, options);}
function formatted_project_path(id, format, verb){ return '/projects/' + id + '.' + format + '';}
function formatted_project_ajax(id, format, verb, params, options){ return less_ajax('/projects/' + id + '.' + format + '', verb, params, options);}
function formatted_project_ajaxx(id, format, verb, params, options){ return less_ajaxx('/projects/' + id + '.' + format + '', verb, params, options);}
function cancel_project_project_subscriptions_path(project_id, verb){ return '/projects/' + project_id + '/project_subscriptions/cancel';}
function cancel_project_project_subscriptions_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/cancel', verb, params, options);}
function cancel_project_project_subscriptions_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/cancel', verb, params, options);}
function formatted_cancel_project_project_subscriptions_path(project_id, format, verb){ return '/projects/' + project_id + '/project_subscriptions/cancel.' + format + '';}
function formatted_cancel_project_project_subscriptions_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/cancel.' + format + '', verb, params, options);}
function formatted_cancel_project_project_subscriptions_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/cancel.' + format + '', verb, params, options);}
function project_project_subscriptions_path(project_id, verb){ return '/projects/' + project_id + '/project_subscriptions';}
function project_project_subscriptions_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions', verb, params, options);}
function project_project_subscriptions_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions', verb, params, options);}
function formatted_project_project_subscriptions_path(project_id, format, verb){ return '/projects/' + project_id + '/project_subscriptions.' + format + '';}
function formatted_project_project_subscriptions_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions.' + format + '', verb, params, options);}
function formatted_project_project_subscriptions_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions.' + format + '', verb, params, options);}
function new_project_project_subscription_path(project_id, verb){ return '/projects/' + project_id + '/project_subscriptions/new';}
function new_project_project_subscription_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/new', verb, params, options);}
function new_project_project_subscription_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/new', verb, params, options);}
function formatted_new_project_project_subscription_path(project_id, format, verb){ return '/projects/' + project_id + '/project_subscriptions/new.' + format + '';}
function formatted_new_project_project_subscription_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/new.' + format + '', verb, params, options);}
function formatted_new_project_project_subscription_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/new.' + format + '', verb, params, options);}
function edit_project_project_subscription_path(project_id, id, verb){ return '/projects/' + project_id + '/project_subscriptions/' + id + '/edit';}
function edit_project_project_subscription_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/' + id + '/edit', verb, params, options);}
function edit_project_project_subscription_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/' + id + '/edit', verb, params, options);}
function formatted_edit_project_project_subscription_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_subscriptions/' + id + '/edit.' + format + '';}
function formatted_edit_project_project_subscription_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_project_project_subscription_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/' + id + '/edit.' + format + '', verb, params, options);}
function project_project_subscription_path(project_id, id, verb){ return '/projects/' + project_id + '/project_subscriptions/' + id + '';}
function project_project_subscription_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/' + id + '', verb, params, options);}
function project_project_subscription_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/' + id + '', verb, params, options);}
function formatted_project_project_subscription_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_subscriptions/' + id + '.' + format + '';}
function formatted_project_project_subscription_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_subscriptions/' + id + '.' + format + '', verb, params, options);}
function formatted_project_project_subscription_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_subscriptions/' + id + '.' + format + '', verb, params, options);}
function unfollow_project_project_followings_path(project_id, verb){ return '/projects/' + project_id + '/project_followings/unfollow';}
function unfollow_project_project_followings_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/unfollow', verb, params, options);}
function unfollow_project_project_followings_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/unfollow', verb, params, options);}
function formatted_unfollow_project_project_followings_path(project_id, format, verb){ return '/projects/' + project_id + '/project_followings/unfollow.' + format + '';}
function formatted_unfollow_project_project_followings_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/unfollow.' + format + '', verb, params, options);}
function formatted_unfollow_project_project_followings_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/unfollow.' + format + '', verb, params, options);}
function project_project_followings_path(project_id, verb){ return '/projects/' + project_id + '/project_followings';}
function project_project_followings_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings', verb, params, options);}
function project_project_followings_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings', verb, params, options);}
function formatted_project_project_followings_path(project_id, format, verb){ return '/projects/' + project_id + '/project_followings.' + format + '';}
function formatted_project_project_followings_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings.' + format + '', verb, params, options);}
function formatted_project_project_followings_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings.' + format + '', verb, params, options);}
function new_project_project_following_path(project_id, verb){ return '/projects/' + project_id + '/project_followings/new';}
function new_project_project_following_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/new', verb, params, options);}
function new_project_project_following_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/new', verb, params, options);}
function formatted_new_project_project_following_path(project_id, format, verb){ return '/projects/' + project_id + '/project_followings/new.' + format + '';}
function formatted_new_project_project_following_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/new.' + format + '', verb, params, options);}
function formatted_new_project_project_following_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/new.' + format + '', verb, params, options);}
function edit_project_project_following_path(project_id, id, verb){ return '/projects/' + project_id + '/project_followings/' + id + '/edit';}
function edit_project_project_following_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/' + id + '/edit', verb, params, options);}
function edit_project_project_following_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/' + id + '/edit', verb, params, options);}
function formatted_edit_project_project_following_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_followings/' + id + '/edit.' + format + '';}
function formatted_edit_project_project_following_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_project_project_following_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/' + id + '/edit.' + format + '', verb, params, options);}
function project_project_following_path(project_id, id, verb){ return '/projects/' + project_id + '/project_followings/' + id + '';}
function project_project_following_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/' + id + '', verb, params, options);}
function project_project_following_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/' + id + '', verb, params, options);}
function formatted_project_project_following_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_followings/' + id + '.' + format + '';}
function formatted_project_project_following_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_followings/' + id + '.' + format + '', verb, params, options);}
function formatted_project_project_following_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_followings/' + id + '.' + format + '', verb, params, options);}
function project_project_comments_path(project_id, verb){ return '/projects/' + project_id + '/project_comments';}
function project_project_comments_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments', verb, params, options);}
function project_project_comments_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments', verb, params, options);}
function formatted_project_project_comments_path(project_id, format, verb){ return '/projects/' + project_id + '/project_comments.' + format + '';}
function formatted_project_project_comments_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments.' + format + '', verb, params, options);}
function formatted_project_project_comments_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments.' + format + '', verb, params, options);}
function new_project_project_comment_path(project_id, verb){ return '/projects/' + project_id + '/project_comments/new';}
function new_project_project_comment_ajax(project_id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/new', verb, params, options);}
function new_project_project_comment_ajaxx(project_id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/new', verb, params, options);}
function formatted_new_project_project_comment_path(project_id, format, verb){ return '/projects/' + project_id + '/project_comments/new.' + format + '';}
function formatted_new_project_project_comment_ajax(project_id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/new.' + format + '', verb, params, options);}
function formatted_new_project_project_comment_ajaxx(project_id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/new.' + format + '', verb, params, options);}
function edit_project_project_comment_path(project_id, id, verb){ return '/projects/' + project_id + '/project_comments/' + id + '/edit';}
function edit_project_project_comment_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/' + id + '/edit', verb, params, options);}
function edit_project_project_comment_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/' + id + '/edit', verb, params, options);}
function formatted_edit_project_project_comment_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_comments/' + id + '/edit.' + format + '';}
function formatted_edit_project_project_comment_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_project_project_comment_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/' + id + '/edit.' + format + '', verb, params, options);}
function project_project_comment_path(project_id, id, verb){ return '/projects/' + project_id + '/project_comments/' + id + '';}
function project_project_comment_ajax(project_id, id, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/' + id + '', verb, params, options);}
function project_project_comment_ajaxx(project_id, id, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/' + id + '', verb, params, options);}
function formatted_project_project_comment_path(project_id, id, format, verb){ return '/projects/' + project_id + '/project_comments/' + id + '.' + format + '';}
function formatted_project_project_comment_ajax(project_id, id, format, verb, params, options){ return less_ajax('/projects/' + project_id + '/project_comments/' + id + '.' + format + '', verb, params, options);}
function formatted_project_project_comment_ajaxx(project_id, id, format, verb, params, options){ return less_ajaxx('/projects/' + project_id + '/project_comments/' + id + '.' + format + '', verb, params, options);}
function project_widgets_path(verb){ return '/project_widgets';}
function project_widgets_ajax(verb, params, options){ return less_ajax('/project_widgets', verb, params, options);}
function project_widgets_ajaxx(verb, params, options){ return less_ajaxx('/project_widgets', verb, params, options);}
function latest_comments_path(verb){ return '/latest_comments';}
function latest_comments_ajax(verb, params, options){ return less_ajax('/latest_comments', verb, params, options);}
function latest_comments_ajaxx(verb, params, options){ return less_ajaxx('/latest_comments', verb, params, options);}
function portfolio_awaiting_payment_profiles_path(verb){ return '/profiles/portfolio_awaiting_payment';}
function portfolio_awaiting_payment_profiles_ajax(verb, params, options){ return less_ajax('/profiles/portfolio_awaiting_payment', verb, params, options);}
function portfolio_awaiting_payment_profiles_ajaxx(verb, params, options){ return less_ajaxx('/profiles/portfolio_awaiting_payment', verb, params, options);}
function formatted_portfolio_awaiting_payment_profiles_path(format, verb){ return '/profiles/portfolio_awaiting_payment.' + format + '';}
function formatted_portfolio_awaiting_payment_profiles_ajax(format, verb, params, options){ return less_ajax('/profiles/portfolio_awaiting_payment.' + format + '', verb, params, options);}
function formatted_portfolio_awaiting_payment_profiles_ajaxx(format, verb, params, options){ return less_ajaxx('/profiles/portfolio_awaiting_payment.' + format + '', verb, params, options);}
function search_profiles_path(verb){ return '/profiles/search';}
function search_profiles_ajax(verb, params, options){ return less_ajax('/profiles/search', verb, params, options);}
function search_profiles_ajaxx(verb, params, options){ return less_ajaxx('/profiles/search', verb, params, options);}
function formatted_search_profiles_path(format, verb){ return '/profiles/search.' + format + '';}
function formatted_search_profiles_ajax(format, verb, params, options){ return less_ajax('/profiles/search.' + format + '', verb, params, options);}
function formatted_search_profiles_ajaxx(format, verb, params, options){ return less_ajaxx('/profiles/search.' + format + '', verb, params, options);}
function profiles_path(verb){ return '/profiles';}
function profiles_ajax(verb, params, options){ return less_ajax('/profiles', verb, params, options);}
function profiles_ajaxx(verb, params, options){ return less_ajaxx('/profiles', verb, params, options);}
function formatted_profiles_path(format, verb){ return '/profiles.' + format + '';}
function formatted_profiles_ajax(format, verb, params, options){ return less_ajax('/profiles.' + format + '', verb, params, options);}
function formatted_profiles_ajaxx(format, verb, params, options){ return less_ajaxx('/profiles.' + format + '', verb, params, options);}
function new_profile_path(verb){ return '/profiles/new';}
function new_profile_ajax(verb, params, options){ return less_ajax('/profiles/new', verb, params, options);}
function new_profile_ajaxx(verb, params, options){ return less_ajaxx('/profiles/new', verb, params, options);}
function formatted_new_profile_path(format, verb){ return '/profiles/new.' + format + '';}
function formatted_new_profile_ajax(format, verb, params, options){ return less_ajax('/profiles/new.' + format + '', verb, params, options);}
function formatted_new_profile_ajaxx(format, verb, params, options){ return less_ajaxx('/profiles/new.' + format + '', verb, params, options);}
function delete_icon_profile_path(id, verb){ return '/profiles/' + id + '/delete_icon';}
function delete_icon_profile_ajax(id, verb, params, options){ return less_ajax('/profiles/' + id + '/delete_icon', verb, params, options);}
function delete_icon_profile_ajaxx(id, verb, params, options){ return less_ajaxx('/profiles/' + id + '/delete_icon', verb, params, options);}
function formatted_delete_icon_profile_path(id, format, verb){ return '/profiles/' + id + '/delete_icon.' + format + '';}
function formatted_delete_icon_profile_ajax(id, format, verb, params, options){ return less_ajax('/profiles/' + id + '/delete_icon.' + format + '', verb, params, options);}
function formatted_delete_icon_profile_ajaxx(id, format, verb, params, options){ return less_ajaxx('/profiles/' + id + '/delete_icon.' + format + '', verb, params, options);}
function edit_profile_path(id, verb){ return '/profiles/' + id + '/edit';}
function edit_profile_ajax(id, verb, params, options){ return less_ajax('/profiles/' + id + '/edit', verb, params, options);}
function edit_profile_ajaxx(id, verb, params, options){ return less_ajaxx('/profiles/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_path(id, format, verb){ return '/profiles/' + id + '/edit.' + format + '';}
function formatted_edit_profile_ajax(id, format, verb, params, options){ return less_ajax('/profiles/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_ajaxx(id, format, verb, params, options){ return less_ajaxx('/profiles/' + id + '/edit.' + format + '', verb, params, options);}
function friend_list_profile_path(id, verb){ return '/profiles/' + id + '/friend_list';}
function friend_list_profile_ajax(id, verb, params, options){ return less_ajax('/profiles/' + id + '/friend_list', verb, params, options);}
function friend_list_profile_ajaxx(id, verb, params, options){ return less_ajaxx('/profiles/' + id + '/friend_list', verb, params, options);}
function formatted_friend_list_profile_path(id, format, verb){ return '/profiles/' + id + '/friend_list.' + format + '';}
function formatted_friend_list_profile_ajax(id, format, verb, params, options){ return less_ajax('/profiles/' + id + '/friend_list.' + format + '', verb, params, options);}
function formatted_friend_list_profile_ajaxx(id, format, verb, params, options){ return less_ajaxx('/profiles/' + id + '/friend_list.' + format + '', verb, params, options);}
function profile_path(id, verb){ return '/profiles/' + id + '';}
function profile_ajax(id, verb, params, options){ return less_ajax('/profiles/' + id + '', verb, params, options);}
function profile_ajaxx(id, verb, params, options){ return less_ajaxx('/profiles/' + id + '', verb, params, options);}
function formatted_profile_path(id, format, verb){ return '/profiles/' + id + '.' + format + '';}
function formatted_profile_ajax(id, format, verb, params, options){ return less_ajax('/profiles/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_ajaxx(id, format, verb, params, options){ return less_ajaxx('/profiles/' + id + '.' + format + '', verb, params, options);}
function profile_friends_path(profile_id, verb){ return '/profiles/' + profile_id + '/friends';}
function profile_friends_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends', verb, params, options);}
function profile_friends_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends', verb, params, options);}
function formatted_profile_friends_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/friends.' + format + '';}
function formatted_profile_friends_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends.' + format + '', verb, params, options);}
function formatted_profile_friends_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends.' + format + '', verb, params, options);}
function new_profile_friend_path(profile_id, verb){ return '/profiles/' + profile_id + '/friends/new';}
function new_profile_friend_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/new', verb, params, options);}
function new_profile_friend_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/new', verb, params, options);}
function formatted_new_profile_friend_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/friends/new.' + format + '';}
function formatted_new_profile_friend_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/new.' + format + '', verb, params, options);}
function formatted_new_profile_friend_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/new.' + format + '', verb, params, options);}
function edit_profile_friend_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/friends/' + id + '/edit';}
function edit_profile_friend_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/' + id + '/edit', verb, params, options);}
function edit_profile_friend_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_friend_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/friends/' + id + '/edit.' + format + '';}
function formatted_edit_profile_friend_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_friend_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/' + id + '/edit.' + format + '', verb, params, options);}
function profile_friend_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/friends/' + id + '';}
function profile_friend_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/' + id + '', verb, params, options);}
function profile_friend_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/' + id + '', verb, params, options);}
function formatted_profile_friend_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/friends/' + id + '.' + format + '';}
function formatted_profile_friend_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/friends/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_friend_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/friends/' + id + '.' + format + '', verb, params, options);}
function profile_blogs_path(profile_id, verb){ return '/profiles/' + profile_id + '/blogs';}
function profile_blogs_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs', verb, params, options);}
function profile_blogs_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs', verb, params, options);}
function formatted_profile_blogs_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/blogs.' + format + '';}
function formatted_profile_blogs_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs.' + format + '', verb, params, options);}
function formatted_profile_blogs_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs.' + format + '', verb, params, options);}
function new_profile_blog_path(profile_id, verb){ return '/profiles/' + profile_id + '/blogs/new';}
function new_profile_blog_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/new', verb, params, options);}
function new_profile_blog_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/new', verb, params, options);}
function formatted_new_profile_blog_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/blogs/new.' + format + '';}
function formatted_new_profile_blog_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/new.' + format + '', verb, params, options);}
function formatted_new_profile_blog_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/new.' + format + '', verb, params, options);}
function edit_profile_blog_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/blogs/' + id + '/edit';}
function edit_profile_blog_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/' + id + '/edit', verb, params, options);}
function edit_profile_blog_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_blog_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/blogs/' + id + '/edit.' + format + '';}
function formatted_edit_profile_blog_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_blog_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/' + id + '/edit.' + format + '', verb, params, options);}
function profile_blog_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/blogs/' + id + '';}
function profile_blog_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/' + id + '', verb, params, options);}
function profile_blog_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/' + id + '', verb, params, options);}
function formatted_profile_blog_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/blogs/' + id + '.' + format + '';}
function formatted_profile_blog_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/blogs/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_blog_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/blogs/' + id + '.' + format + '', verb, params, options);}
function profile_photos_path(profile_id, verb){ return '/profiles/' + profile_id + '/photos';}
function profile_photos_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos', verb, params, options);}
function profile_photos_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos', verb, params, options);}
function formatted_profile_photos_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/photos.' + format + '';}
function formatted_profile_photos_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos.' + format + '', verb, params, options);}
function formatted_profile_photos_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos.' + format + '', verb, params, options);}
function new_profile_photo_path(profile_id, verb){ return '/profiles/' + profile_id + '/photos/new';}
function new_profile_photo_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/new', verb, params, options);}
function new_profile_photo_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/new', verb, params, options);}
function formatted_new_profile_photo_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/photos/new.' + format + '';}
function formatted_new_profile_photo_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/new.' + format + '', verb, params, options);}
function formatted_new_profile_photo_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/new.' + format + '', verb, params, options);}
function edit_profile_photo_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/photos/' + id + '/edit';}
function edit_profile_photo_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/' + id + '/edit', verb, params, options);}
function edit_profile_photo_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_photo_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/photos/' + id + '/edit.' + format + '';}
function formatted_edit_profile_photo_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_photo_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/' + id + '/edit.' + format + '', verb, params, options);}
function profile_photo_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/photos/' + id + '';}
function profile_photo_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/' + id + '', verb, params, options);}
function profile_photo_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/' + id + '', verb, params, options);}
function formatted_profile_photo_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/photos/' + id + '.' + format + '';}
function formatted_profile_photo_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/photos/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_photo_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/photos/' + id + '.' + format + '', verb, params, options);}
function profile_comments_path(profile_id, verb){ return '/profiles/' + profile_id + '/comments';}
function profile_comments_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments', verb, params, options);}
function profile_comments_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments', verb, params, options);}
function formatted_profile_comments_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/comments.' + format + '';}
function formatted_profile_comments_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments.' + format + '', verb, params, options);}
function formatted_profile_comments_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments.' + format + '', verb, params, options);}
function new_profile_comment_path(profile_id, verb){ return '/profiles/' + profile_id + '/comments/new';}
function new_profile_comment_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/new', verb, params, options);}
function new_profile_comment_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/new', verb, params, options);}
function formatted_new_profile_comment_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/comments/new.' + format + '';}
function formatted_new_profile_comment_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/new.' + format + '', verb, params, options);}
function formatted_new_profile_comment_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/new.' + format + '', verb, params, options);}
function edit_profile_comment_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/comments/' + id + '/edit';}
function edit_profile_comment_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/' + id + '/edit', verb, params, options);}
function edit_profile_comment_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_comment_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/comments/' + id + '/edit.' + format + '';}
function formatted_edit_profile_comment_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_comment_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/' + id + '/edit.' + format + '', verb, params, options);}
function profile_comment_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/comments/' + id + '';}
function profile_comment_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/' + id + '', verb, params, options);}
function profile_comment_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/' + id + '', verb, params, options);}
function formatted_profile_comment_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/comments/' + id + '.' + format + '';}
function formatted_profile_comment_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/comments/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_comment_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/comments/' + id + '.' + format + '', verb, params, options);}
function profile_feed_items_path(profile_id, verb){ return '/profiles/' + profile_id + '/feed_items';}
function profile_feed_items_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items', verb, params, options);}
function profile_feed_items_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items', verb, params, options);}
function formatted_profile_feed_items_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/feed_items.' + format + '';}
function formatted_profile_feed_items_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items.' + format + '', verb, params, options);}
function formatted_profile_feed_items_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items.' + format + '', verb, params, options);}
function new_profile_feed_item_path(profile_id, verb){ return '/profiles/' + profile_id + '/feed_items/new';}
function new_profile_feed_item_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/new', verb, params, options);}
function new_profile_feed_item_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/new', verb, params, options);}
function formatted_new_profile_feed_item_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/feed_items/new.' + format + '';}
function formatted_new_profile_feed_item_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/new.' + format + '', verb, params, options);}
function formatted_new_profile_feed_item_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/new.' + format + '', verb, params, options);}
function edit_profile_feed_item_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/feed_items/' + id + '/edit';}
function edit_profile_feed_item_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/' + id + '/edit', verb, params, options);}
function edit_profile_feed_item_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_feed_item_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/feed_items/' + id + '/edit.' + format + '';}
function formatted_edit_profile_feed_item_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_feed_item_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/' + id + '/edit.' + format + '', verb, params, options);}
function profile_feed_item_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/feed_items/' + id + '';}
function profile_feed_item_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/' + id + '', verb, params, options);}
function profile_feed_item_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/' + id + '', verb, params, options);}
function formatted_profile_feed_item_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/feed_items/' + id + '.' + format + '';}
function formatted_profile_feed_item_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/feed_items/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_feed_item_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/feed_items/' + id + '.' + format + '', verb, params, options);}
function profile_messages_path(profile_id, verb){ return '/profiles/' + profile_id + '/messages';}
function profile_messages_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages', verb, params, options);}
function profile_messages_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages', verb, params, options);}
function formatted_profile_messages_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/messages.' + format + '';}
function formatted_profile_messages_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages.' + format + '', verb, params, options);}
function formatted_profile_messages_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages.' + format + '', verb, params, options);}
function new_profile_message_path(profile_id, verb){ return '/profiles/' + profile_id + '/messages/new';}
function new_profile_message_ajax(profile_id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/new', verb, params, options);}
function new_profile_message_ajaxx(profile_id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/new', verb, params, options);}
function formatted_new_profile_message_path(profile_id, format, verb){ return '/profiles/' + profile_id + '/messages/new.' + format + '';}
function formatted_new_profile_message_ajax(profile_id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/new.' + format + '', verb, params, options);}
function formatted_new_profile_message_ajaxx(profile_id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/new.' + format + '', verb, params, options);}
function edit_profile_message_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/messages/' + id + '/edit';}
function edit_profile_message_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/' + id + '/edit', verb, params, options);}
function edit_profile_message_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/' + id + '/edit', verb, params, options);}
function formatted_edit_profile_message_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/messages/' + id + '/edit.' + format + '';}
function formatted_edit_profile_message_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_profile_message_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/' + id + '/edit.' + format + '', verb, params, options);}
function profile_message_path(profile_id, id, verb){ return '/profiles/' + profile_id + '/messages/' + id + '';}
function profile_message_ajax(profile_id, id, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/' + id + '', verb, params, options);}
function profile_message_ajaxx(profile_id, id, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/' + id + '', verb, params, options);}
function formatted_profile_message_path(profile_id, id, format, verb){ return '/profiles/' + profile_id + '/messages/' + id + '.' + format + '';}
function formatted_profile_message_ajax(profile_id, id, format, verb, params, options){ return less_ajax('/profiles/' + profile_id + '/messages/' + id + '.' + format + '', verb, params, options);}
function formatted_profile_message_ajaxx(profile_id, id, format, verb, params, options){ return less_ajaxx('/profiles/' + profile_id + '/messages/' + id + '.' + format + '', verb, params, options);}
function sent_messages_path(verb){ return '/messages/sent';}
function sent_messages_ajax(verb, params, options){ return less_ajax('/messages/sent', verb, params, options);}
function sent_messages_ajaxx(verb, params, options){ return less_ajaxx('/messages/sent', verb, params, options);}
function formatted_sent_messages_path(format, verb){ return '/messages/sent.' + format + '';}
function formatted_sent_messages_ajax(format, verb, params, options){ return less_ajax('/messages/sent.' + format + '', verb, params, options);}
function formatted_sent_messages_ajaxx(format, verb, params, options){ return less_ajaxx('/messages/sent.' + format + '', verb, params, options);}
function messages_path(verb){ return '/messages';}
function messages_ajax(verb, params, options){ return less_ajax('/messages', verb, params, options);}
function messages_ajaxx(verb, params, options){ return less_ajaxx('/messages', verb, params, options);}
function formatted_messages_path(format, verb){ return '/messages.' + format + '';}
function formatted_messages_ajax(format, verb, params, options){ return less_ajax('/messages.' + format + '', verb, params, options);}
function formatted_messages_ajaxx(format, verb, params, options){ return less_ajaxx('/messages.' + format + '', verb, params, options);}
function new_message_path(verb){ return '/messages/new';}
function new_message_ajax(verb, params, options){ return less_ajax('/messages/new', verb, params, options);}
function new_message_ajaxx(verb, params, options){ return less_ajaxx('/messages/new', verb, params, options);}
function formatted_new_message_path(format, verb){ return '/messages/new.' + format + '';}
function formatted_new_message_ajax(format, verb, params, options){ return less_ajax('/messages/new.' + format + '', verb, params, options);}
function formatted_new_message_ajaxx(format, verb, params, options){ return less_ajaxx('/messages/new.' + format + '', verb, params, options);}
function edit_message_path(id, verb){ return '/messages/' + id + '/edit';}
function edit_message_ajax(id, verb, params, options){ return less_ajax('/messages/' + id + '/edit', verb, params, options);}
function edit_message_ajaxx(id, verb, params, options){ return less_ajaxx('/messages/' + id + '/edit', verb, params, options);}
function formatted_edit_message_path(id, format, verb){ return '/messages/' + id + '/edit.' + format + '';}
function formatted_edit_message_ajax(id, format, verb, params, options){ return less_ajax('/messages/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_message_ajaxx(id, format, verb, params, options){ return less_ajaxx('/messages/' + id + '/edit.' + format + '', verb, params, options);}
function message_path(id, verb){ return '/messages/' + id + '';}
function message_ajax(id, verb, params, options){ return less_ajax('/messages/' + id + '', verb, params, options);}
function message_ajaxx(id, verb, params, options){ return less_ajaxx('/messages/' + id + '', verb, params, options);}
function formatted_message_path(id, format, verb){ return '/messages/' + id + '.' + format + '';}
function formatted_message_ajax(id, format, verb, params, options){ return less_ajax('/messages/' + id + '.' + format + '', verb, params, options);}
function formatted_message_ajaxx(id, format, verb, params, options){ return less_ajaxx('/messages/' + id + '.' + format + '', verb, params, options);}
function update_positions_forums_path(verb){ return '/forums/update_positions';}
function update_positions_forums_ajax(verb, params, options){ return less_ajax('/forums/update_positions', verb, params, options);}
function update_positions_forums_ajaxx(verb, params, options){ return less_ajaxx('/forums/update_positions', verb, params, options);}
function formatted_update_positions_forums_path(format, verb){ return '/forums/update_positions.' + format + '';}
function formatted_update_positions_forums_ajax(format, verb, params, options){ return less_ajax('/forums/update_positions.' + format + '', verb, params, options);}
function formatted_update_positions_forums_ajaxx(format, verb, params, options){ return less_ajaxx('/forums/update_positions.' + format + '', verb, params, options);}
function forums_path(verb){ return '/forums';}
function forums_ajax(verb, params, options){ return less_ajax('/forums', verb, params, options);}
function forums_ajaxx(verb, params, options){ return less_ajaxx('/forums', verb, params, options);}
function formatted_forums_path(format, verb){ return '/forums.' + format + '';}
function formatted_forums_ajax(format, verb, params, options){ return less_ajax('/forums.' + format + '', verb, params, options);}
function formatted_forums_ajaxx(format, verb, params, options){ return less_ajaxx('/forums.' + format + '', verb, params, options);}
function new_forum_path(verb){ return '/forums/new';}
function new_forum_ajax(verb, params, options){ return less_ajax('/forums/new', verb, params, options);}
function new_forum_ajaxx(verb, params, options){ return less_ajaxx('/forums/new', verb, params, options);}
function formatted_new_forum_path(format, verb){ return '/forums/new.' + format + '';}
function formatted_new_forum_ajax(format, verb, params, options){ return less_ajax('/forums/new.' + format + '', verb, params, options);}
function formatted_new_forum_ajaxx(format, verb, params, options){ return less_ajaxx('/forums/new.' + format + '', verb, params, options);}
function edit_forum_path(id, verb){ return '/forums/' + id + '/edit';}
function edit_forum_ajax(id, verb, params, options){ return less_ajax('/forums/' + id + '/edit', verb, params, options);}
function edit_forum_ajaxx(id, verb, params, options){ return less_ajaxx('/forums/' + id + '/edit', verb, params, options);}
function formatted_edit_forum_path(id, format, verb){ return '/forums/' + id + '/edit.' + format + '';}
function formatted_edit_forum_ajax(id, format, verb, params, options){ return less_ajax('/forums/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_forum_ajaxx(id, format, verb, params, options){ return less_ajaxx('/forums/' + id + '/edit.' + format + '', verb, params, options);}
function forum_path(id, verb){ return '/forums/' + id + '';}
function forum_ajax(id, verb, params, options){ return less_ajax('/forums/' + id + '', verb, params, options);}
function forum_ajaxx(id, verb, params, options){ return less_ajaxx('/forums/' + id + '', verb, params, options);}
function formatted_forum_path(id, format, verb){ return '/forums/' + id + '.' + format + '';}
function formatted_forum_ajax(id, format, verb, params, options){ return less_ajax('/forums/' + id + '.' + format + '', verb, params, options);}
function formatted_forum_ajaxx(id, format, verb, params, options){ return less_ajaxx('/forums/' + id + '.' + format + '', verb, params, options);}
function forum_topics_path(forum_id, verb){ return '/forums/' + forum_id + '/topics';}
function forum_topics_ajax(forum_id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics', verb, params, options);}
function forum_topics_ajaxx(forum_id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics', verb, params, options);}
function formatted_forum_topics_path(forum_id, format, verb){ return '/forums/' + forum_id + '/topics.' + format + '';}
function formatted_forum_topics_ajax(forum_id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics.' + format + '', verb, params, options);}
function formatted_forum_topics_ajaxx(forum_id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics.' + format + '', verb, params, options);}
function new_forum_topic_path(forum_id, verb){ return '/forums/' + forum_id + '/topics/new';}
function new_forum_topic_ajax(forum_id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/new', verb, params, options);}
function new_forum_topic_ajaxx(forum_id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/new', verb, params, options);}
function formatted_new_forum_topic_path(forum_id, format, verb){ return '/forums/' + forum_id + '/topics/new.' + format + '';}
function formatted_new_forum_topic_ajax(forum_id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/new.' + format + '', verb, params, options);}
function formatted_new_forum_topic_ajaxx(forum_id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/new.' + format + '', verb, params, options);}
function edit_forum_topic_path(forum_id, id, verb){ return '/forums/' + forum_id + '/topics/' + id + '/edit';}
function edit_forum_topic_ajax(forum_id, id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + id + '/edit', verb, params, options);}
function edit_forum_topic_ajaxx(forum_id, id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + id + '/edit', verb, params, options);}
function formatted_edit_forum_topic_path(forum_id, id, format, verb){ return '/forums/' + forum_id + '/topics/' + id + '/edit.' + format + '';}
function formatted_edit_forum_topic_ajax(forum_id, id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_forum_topic_ajaxx(forum_id, id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + id + '/edit.' + format + '', verb, params, options);}
function forum_topic_path(forum_id, id, verb){ return '/forums/' + forum_id + '/topics/' + id + '';}
function forum_topic_ajax(forum_id, id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + id + '', verb, params, options);}
function forum_topic_ajaxx(forum_id, id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + id + '', verb, params, options);}
function formatted_forum_topic_path(forum_id, id, format, verb){ return '/forums/' + forum_id + '/topics/' + id + '.' + format + '';}
function formatted_forum_topic_ajax(forum_id, id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + id + '.' + format + '', verb, params, options);}
function formatted_forum_topic_ajaxx(forum_id, id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + id + '.' + format + '', verb, params, options);}
function forum_topic_posts_path(forum_id, topic_id, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts';}
function forum_topic_posts_ajax(forum_id, topic_id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts', verb, params, options);}
function forum_topic_posts_ajaxx(forum_id, topic_id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts', verb, params, options);}
function formatted_forum_topic_posts_path(forum_id, topic_id, format, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts.' + format + '';}
function formatted_forum_topic_posts_ajax(forum_id, topic_id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts.' + format + '', verb, params, options);}
function formatted_forum_topic_posts_ajaxx(forum_id, topic_id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts.' + format + '', verb, params, options);}
function new_forum_topic_post_path(forum_id, topic_id, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/new';}
function new_forum_topic_post_ajax(forum_id, topic_id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/new', verb, params, options);}
function new_forum_topic_post_ajaxx(forum_id, topic_id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/new', verb, params, options);}
function formatted_new_forum_topic_post_path(forum_id, topic_id, format, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/new.' + format + '';}
function formatted_new_forum_topic_post_ajax(forum_id, topic_id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/new.' + format + '', verb, params, options);}
function formatted_new_forum_topic_post_ajaxx(forum_id, topic_id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/new.' + format + '', verb, params, options);}
function edit_forum_topic_post_path(forum_id, topic_id, id, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit';}
function edit_forum_topic_post_ajax(forum_id, topic_id, id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit', verb, params, options);}
function edit_forum_topic_post_ajaxx(forum_id, topic_id, id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit', verb, params, options);}
function formatted_edit_forum_topic_post_path(forum_id, topic_id, id, format, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit.' + format + '';}
function formatted_edit_forum_topic_post_ajax(forum_id, topic_id, id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit.' + format + '', verb, params, options);}
function formatted_edit_forum_topic_post_ajaxx(forum_id, topic_id, id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '/edit.' + format + '', verb, params, options);}
function forum_topic_post_path(forum_id, topic_id, id, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '';}
function forum_topic_post_ajax(forum_id, topic_id, id, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '', verb, params, options);}
function forum_topic_post_ajaxx(forum_id, topic_id, id, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '', verb, params, options);}
function formatted_forum_topic_post_path(forum_id, topic_id, id, format, verb){ return '/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '.' + format + '';}
function formatted_forum_topic_post_ajax(forum_id, topic_id, id, format, verb, params, options){ return less_ajax('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '.' + format + '', verb, params, options);}
function formatted_forum_topic_post_ajaxx(forum_id, topic_id, id, format, verb, params, options){ return less_ajaxx('/forums/' + forum_id + '/topics/' + topic_id + '/posts/' + id + '.' + format + '', verb, params, options);}
function login_path(verb){ return '/login';}
function login_ajax(verb, params, options){ return less_ajax('/login', verb, params, options);}
function login_ajaxx(verb, params, options){ return less_ajaxx('/login', verb, params, options);}
function logout_path(verb){ return '/logout';}
function logout_ajax(verb, params, options){ return less_ajax('/logout', verb, params, options);}
function logout_ajaxx(verb, params, options){ return less_ajaxx('/logout', verb, params, options);}
function signup_path(verb){ return '/signup';}
function signup_ajax(verb, params, options){ return less_ajax('/signup', verb, params, options);}
function signup_ajaxx(verb, params, options){ return less_ajaxx('/signup', verb, params, options);}
function activate_path(verb){ return '/activate';}
function activate_ajax(verb, params, options){ return less_ajax('/activate', verb, params, options);}
function activate_ajaxx(verb, params, options){ return less_ajaxx('/activate', verb, params, options);}
function home_path(verb){ return '/home';}
function home_ajax(verb, params, options){ return less_ajax('/home', verb, params, options);}
function home_ajaxx(verb, params, options){ return less_ajaxx('/home', verb, params, options);}
function search_path(verb){ return '/home/search';}
function search_ajax(verb, params, options){ return less_ajax('/home/search', verb, params, options);}
function search_ajaxx(verb, params, options){ return less_ajaxx('/home/search', verb, params, options);}
function login_vanity_path(userlogin, verb){ return '/' + userlogin + '';}
function login_vanity_ajax(userlogin, verb, params, options){ return less_ajax('/' + userlogin + '', verb, params, options);}
function login_vanity_ajaxx(userlogin, verb, params, options){ return less_ajaxx('/' + userlogin + '', verb, params, options);}
function root_path(verb){ return '';}
function root_ajax(verb, params, options){ return less_ajax('', verb, params, options);}
function root_ajaxx(verb, params, options){ return less_ajaxx('', verb, params, options);}
function static_path(action, verb){ return '/pages/' + action + '';}
function static_ajax(action, verb, params, options){ return less_ajax('/pages/' + action + '', verb, params, options);}
function static_ajaxx(action, verb, params, options){ return less_ajaxx('/pages/' + action + '', verb, params, options);}
