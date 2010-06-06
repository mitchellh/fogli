require 'httparty'

# Try to load the Rails ActiveSupport module accessors
# But fall back to our own if it doesn't exist.
begin
  require 'active_support/core_ext/module/attribute_accessors'
rescue LoadError
  require 'fogli/util/module_attributes'
end

module Fogli
  # The configuration options below only need to be set if you
  # wish to retrieve authorized information via the Graph API.
  # The configuration keys should be self explanatory.
  mattr_accessor :client_id
  mattr_accessor :client_secret
  mattr_accessor :access_token

  autoload :User, 'fogli/user'
  autoload :FacebookObject, 'fogli/facebook_object'
  autoload :RootFacebookObject, 'fogli/root_facebook_object'
end
