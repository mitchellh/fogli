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
  mattr_accessor :redirect_uri
  mattr_accessor :access_token

  autoload :Exception, 'fogli/exception'
  autoload :FacebookGraph, 'fogli/facebook_graph'
  autoload :FacebookObject, 'fogli/facebook_object'

  # User-friendly models
  autoload :Album, 'fogli/album'
  autoload :CategorizedObject, 'fogli/categorized_object'
  autoload :Comment, 'fogli/comment'
  autoload :Event, 'fogli/event'
  autoload :Group, 'fogli/group'
  autoload :Link, 'fogli/link'
  autoload :NamedObject, 'fogli/named_object'
  autoload :Note, 'fogli/note'
  autoload :OAuth, 'fogli/oauth'
  autoload :Page, 'fogli/page'
  autoload :Photo, 'fogli/photo'
  autoload :Post, 'fogli/post'
  autoload :Status, 'fogli/status'
  autoload :User, 'fogli/user'
  autoload :Video, 'fogli/video'

  module Util
    autoload :Options, 'fogli/util/options'
  end
end
