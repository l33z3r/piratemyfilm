# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#

every 10.minutes do
  rake "update_max_blog"
end

every 1.day, :at => '1:00 am' do
  rake "generate_project_change_info"
end

every 1.day, :at => '1:00 am' do
  rake "payment_window_rollovers"
end

every 3.days, :at => '1:00 am' do
  rake "clear_expired_sessions"
end

# Learn more: http://github.com/javan/whenever
