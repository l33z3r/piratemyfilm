# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

config.log_level = :info

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# needed for Avatar::Source::RailsAssetSource
config.action_controller.asset_host                  = "http://piratemyfilm.piratemyfilm-001.vm.brightbox.net"

config.action_mailer.default_url_options[:host] = "http://piratemyfilm.piratemyfilm-001.vm.brightbox.net"


# Disable delivery errors, bad email addresses will be ignored
#config.action_mailer.raise_delivery_errors = false

ActionMailer::Base.smtp_settings = {
  :address  => "smtp-relay.brightbox.net",
  :port  => 25, 
  :domain  => "brightbox.net"
}
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true

config.cache_store = :mem_cache_store

