require 'fogli/facebook_object/properties'
require 'fogli/facebook_object/connections'

module Fogli
  # Represents any facebook object. This exposes the common
  # abstractions used by every other facebook object such as the
  # concept of properties and connections.
  class FacebookObject < FacebookGraph
    autoload :ConnectionProxy, 'fogli/facebook_object/connection_proxy'

    include Properties
    include Connections

    # Every facebook object has an id and typically an updated time
    # (if authorized)
    property :id, :updated_time

    # Propagates the properties and connections to any subclasses
    # which inherit from FacebookObject. This method is called
    # automatically by Ruby.
    def self.inherited(subclass)
      super

      propagate_properties(subclass)
      propagate_connections(subclass)
    end

    # Initialize a facebook object. If given some data, it will
    # attempt to populate the various properties with the given data.
    #
    # @param [Hash] data The data for this object.
    def initialize(data=nil)
      populate_properties(data) if data
    end
  end
end
