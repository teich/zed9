    # Pull in the ZiYa gem framework
    gem "derailed-ziya", ">= 2.0.0"
    require 'ziya'

    # Initializes the ZiYa Framework
    Ziya.initialize(
      :logger      => RAILS_DEFAULT_LOGGER,
      :helpers_dir => File.join( File.dirname(__FILE__), %w[.. .. app helpers ziya] ),
      :themes_dir  => File.join( File.dirname(__FILE__), %w[.. .. public charts themes])
    )
