
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # Cookie sessions (limit = 4K)
  config.action_controller.session = {
    :session_key => 'p1rat3',
    :secret      => 'p1rat3_s3cret'
  }
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  
  # Gem dependencies
  config.gem 'will_paginate', :version => '~> 2.2.2'
  config.gem 'colored', :version=> '1.1'
  config.gem 'youtube-g', :version=> '0.4.1', :lib=>'youtube_g'
  config.gem 'uuidtools', :version=> '1.0.3'
  config.gem 'acts_as_ferret', :version=> '0.4.3'
  config.gem 'ferret', :version=> '0.11.4'
  config.gem 'hpricot', :version=> '0.8.1'
  config.gem 'mocha', :version=>"0.5.6"
  config.gem 'redgreen', :version=>"1.2.2" unless ENV['TM_MODE']
  config.gem 'gcnovus-avatar', :version=>"0.0.7", :lib => 'avatar'
  config.gem "recaptcha", :lib => "recaptcha/rails"

end

Less::JsRoutes.generate!
