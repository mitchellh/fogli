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

    class << self
      # Finds the facebook object associated with the given `id` by
      # accessing the graph API directly:
      #
      #     http://graph.facebook.com/id
      #
      # The data is then parsed and the resulting object instance is
      # returned. If no object is found, nil is returned.
      #
      # An additional options hash may be passed into {find}, which
      # can be used for things like `:fields` or `:metadata`.
      #
      # @param [String] id ID of the object
      # @param [Hash] options A hash of additional options. More info
      #   above.
      def find(id, options=nil)
        # TODO: Do something with options
        new(get("/#{id}"))
      end
      alias :[] :find

      # Propagates the properties and connections to any subclasses
      # which inherit from FacebookObject. This method is called
      # automatically by Ruby.
      def inherited(subclass)
        super

        propagate_properties(subclass)
        propagate_connections(subclass)
      end
    end

    # Initialize a facebook object. If given some data, it will
    # attempt to populate the various properties with the given data.
    #
    # @param [Hash] data The data for this object.
    def initialize(data=nil)
      populate_properties(data) if data
    end

    # Delete an object. This always requires an access token. If you
    # do not yet have an access token, you must get one via {OAuth}.
    def delete
      super("/#{id}")
    end

    # Override `FacebookGraph#get` to prepend object ID. When calling
    # {#get} on an instance of a facebook object, its typically
    # to access a connection. To avoid repetition, we always prepend
    # the root object's ID.
    def get(url, *args)
      super("/#{id}#{url}", *args)
    end

    # Customize the inspect method to pretty print Facebook objects
    # and their associated properties and connections.
    def inspect
      values = []
      self.class.properties.each do |name, options|
        value = read_property(name)
        values << "#{name.inspect}=#{value.inspect}"
      end

      self.class.connections.each do |name, options|
        values.push("#{name.inspect}=...")
      end

      "#<#{self.class} #{values.sort.join(", ")}>".strip
    end
  end
end
