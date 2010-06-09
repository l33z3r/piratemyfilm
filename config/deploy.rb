## Generated with 'brightbox' on Mon Jan 05 08:34:46 +0000 2009
gem 'brightbox', '>=2.2.2'
require 'brightbox/recipes'
require 'brightbox/passenger'

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "piratemyfilm"

# Primary domain name of your application. Used in the Apache configs
set :domain, "www.piratemyfilm.com"
set :domain_aliases, "piratemyfilm.com,*.piratemyfilm.com"

## List of servers
server "piratemyfilm-001.vm.brightbox.net", :app, :web, :db, :primary => true

# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, application) }

# URL of your source repository. This is the default one that comes on 
# every Brightbox, you can use your own (we'll let you :)
set :scm, :git
set :repository, "git@github.com:l33z3r/piratemyfilm.git"
set :deploy_via, :remote_cache
set :keep_releases, 5

### Other options you can set ##
# Comma separated list of additional domains for Apache
# set :domain_aliases, "www.example.com,dev.example.com"

## Local Shared Area
# These are the list of files and directories that you want
# to share between the releases of your application on a particular
# server. It uses the same shared area as the log files.
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :local_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :local_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
set :local_shared_dirs, %w(public/system)
set :local_shared_files, %w(config/database.yml)

## Global Shared Area
# These are the list of files and directories that you want
# to share between all releases of your application across all servers.
# For it to work you need a directory on a network file server shared
# between all your servers. Specify the path to the root of that area
# in :global_shared_path. Defaults to the same value as :shared_path.
# set :global_shared_path, "/srv/share/myapp"
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# Beyond that it is the same as the local shared area.
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :global_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :global_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
# set :global_shared_dirs, %w(public/upload)
# set :global_shared_files, %w(config/database.yml)

# SSL Certificates. If you specify an SSL certificate name then
# the gem will create an 'https' configuration for this application
# TODO: Upload and install the keys on the server
# set :ssl_certificate, "/path/to/certificate/for/my_app.crt"
# set :ssl_key, "/path/to/key/for/my_app.key
# or
# set :ssl_certificate, "name_of_installed_certificate"

## Static asset caching.
# By default static assets served directly by the web server are
# cached by the client web browser for 10 years, and cache invalidation
# of static assets is handled by the Rails helpers using asset
# timestamping.
# You may need to adjust this value if you have hard coded static
# assets, or other special cache requirements. The value is in seconds.
# set :max_age, 315360000

# SSH options. The forward agent option is used so that loopback logins
# with keys work properly
# ssh_options[:forward_agent] = true

# Forces a Pty so that svn+ssh repository access will work. You
# don't need this if you are using a different SCM system. Note that
# ptys stop shell startup scripts from running.
default_run_options[:pty] = true

## Logrotation
# Where the logs are stored. Defaults to <shared_path>/log
# set :log_dir, "central/log/path"
# The size at which to rotate a log. e.g 1G, 100M, 5M. Defaults to 100M
# set :log_max_size, "100M"
# How many old compressed logs to keep. Defaults to 10
# set :log_keep, "10"

## Version Control System
# Which version control system. Defaults to subversion if there is
# no 'set :scm' command.
# set :scm, :git
# set :scm_username, "rails"
# set :scm_password, "mysecret"
# or be explicit
# set :scm, :subversion

## Mongrel settings
# Addresses that Mongrel listens on. Defaults to :local
# Use :remote if your mongrels are on a different host to the web
# server.
# set :mongrel_host, :local
# set :mongrel_host, :remote
# set :mongrel_host, "192.168.1.1"
# Port number where mongrel starts. Defaults to 9200
# set :mongrel_port, 9200
# Number of mongrel servers to start. Defaults to 2
# set :mongrel_servers, 2

## Mongrel monitoring settings
# Url to check to make sure application is working.
# Defaults to "http://localhost"
# set :mongrel_check_url, "http://localhost"
# set :mongrel_check_url, "http://user:password@localhost/path/to/check"
# Maximum amount of memory to use per mongrel instance. Default 110Mb
# set :mongrel_max_memory, 110
# Maximum cpu allowable per mongrel. Defaults to 80%
# set :mongrel_max_cpu, 80

## Deployment settings
# The brightbox gem deploys as the user 'rails' by default and
# into the 'production' environment. You can change these as required.
# set :user, "rails"
# set :rails_env, :production

## Command running settings
# use_sudo is switched off by default so that commands are run
# directly as 'user' by the run command. If you switch on sudo
# make sure you set the :runner variable - which is the user the
# capistrano default tasks use to execute commands.
# NB. This just affects the default recipes unless you use the
# 'try_sudo' command to run your commands.
# set :use_sudo, false
# set :runner, user

## Dependencies
# Set the commands and gems that your application requires. e.g.
# depend :remote, :gem, "will_paginate", ">=2.2.2"
# depend :remote, :command, "brightbox"
depend :remote, :gem, "hpricot", "0.8.1"

after "deploy:restart", "ferret:stop"
after "ferret:stop", "ferret:index"
after "ferret:index", "ferret:start"

namespace :ferret do 
  desc "Ferret Stop"
  task :stop do
    run "cd #{current_path} && #{current_path}/script/ferret_server -e production stop"
  end

  desc "Ferret Index"
  task :start do
    run "rake ferret_index"
  end

  desc "Ferret Start"
  task :start do
    run "cd #{current_path} && #{current_path}/script/ferret_server -e production start"
  end
end

after "deploy:symlink", "deploy:update_crontab"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end