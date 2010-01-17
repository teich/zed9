# Be sure to restart your server when you modify this file

RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem "authlogic"
  config.gem "hrmparser"
  config.gem "aws-s3", :lib => "aws/s3"
  config.gem "paperclip"
  config.gem "right_aws"
  config.gem 'will_paginate', :version => '~> 2.3.11'

  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_zed9_session',
    :secret      => 'e247bd545d84f4e69e8d90765a6de2753f8fbf14ad1ed7fa734a682c025e7b0e2cad8e4b3549bf943e48072faaefa1ae998f44474a35c3dc3ceb12ca12626e35'
  }

end
