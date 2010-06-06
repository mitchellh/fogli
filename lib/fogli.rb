# Try to load the Rails ActiveSupport module accessors
# But fall back to our own if it doesn't exist.
begin
  require 'active_support/core_ext/module/attribute_accessors'
rescue LoadError
  require 'fogli/util/module_attributes'
end

module Fogli
  # Facebook client ID and secret. These are gained from registering
  # an app with Facebook.
  mattr_accessor :client_id
  mattr_accessor :client_secret

  # Set the access token for Fogli to use priveleged calls.
  mattr_accessor :access_token
end
