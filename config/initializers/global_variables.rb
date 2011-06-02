DELETE_CONFIRM = "Are you sure you want to delete?\nThis can not be undone."
SEARCH_LIMIT = 25
SITE_NAME = 'PirateMyFilm'
SITE = RAILS_ENV == 'production' ? 'http://www.piratemyfilm.com' : 'localhost:3000'

MAILER_TO_ADDRESS = 'info@piratemyfilm.com'
MAILER_FROM_ADDRESS =  %("The PirateMyFilm Team" <info@piratemyfilm.com>)
REGISTRATION_RECIPIENTS = %W(l33z3r@gmail.com) #send an email to this list everytime someone signs up

YOUTUBE_BASE_URL = "http://gdata.youtube.com/feeds/api/videos/"

#some ids of various users
PMF_FUND_ACCOUNT_ID = CUSTOM_CONFIG['max_profile_id']
MAXRIOT_PROFILE_ID = CUSTOM_CONFIG['maxriot_profile_id']

#these are used to log into a remote wordpress site to cross post blogs
WP_SITE_LOGIN_NAME = CUSTOM_CONFIG['wordpress_site_login_name']
WP_SITE_LOGIN_PW = CUSTOM_CONFIG['wordpress_site_login_pw']
WP_SITE_URL = CUSTOM_CONFIG['wordpress_site_url']