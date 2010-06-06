require 'fogli/facebook_object/properties'
require 'fogli/facebook_object/connections'

module Fogli
  # Represents any facebook object. This exposes the common
  # abstractions used by every other facebook object such as the
  # concept of properties and connections.
  class FacebookObject < FacebookGraph
    include Properties
    include Connections

    # Every facebook object has an id and typically an updated time
    # (if authorized)
    property :id, :updated_time

    # Propagates the properties and connections to any subclasses
    # which inherit from FacebookObject. This method is called
    # automatically by Ruby.
    def self.inherited(subclass)
      propagate_properties(subclass)
      propagate_connections(subclass)
    end
  end
end
