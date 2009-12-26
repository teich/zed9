# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "authlogic"
  config.gem "hrmparser"
  config.gem "paperclip"
  config.gem 'will_paginate', :version => '~> 2.3.11'

  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_zed9_session',
    :secret      => 'e247bd545d84f4e69e8d90765a6de2753f8fbf14ad1ed7fa734a682c025e7b0e2cad8e4b3549bf943e48072faaefa1ae998f44474a35c3dc3ceb12ca12626e35'
  }

end
