require 'fogli/facebook_object/scope_methods'

module Fogli
  class FacebookObject < FacebookGraph
    # The proxy object which sits between a facebook object and one of
    # it's connections. This connection proxy only represents
    # connections which are a "has many" type, which happens to be
    # every connection represented by the Facebook Graph except for
    # "picture" which is handled as a special case.
    class ConnectionProxy
      include ScopeMethods

      attr_reader :parent
      attr_reader :connection_name
      attr_reader :connection_options

      # Initializes a connection proxy. The actual data associated
      # with the proxy is not actually loaded until {#load!} is called.
      #
      # @param [FacebookObject] parent The parent object of the
      #   connection
      # @param [Symbol] connection_name The name of the connection,
      #   such as 'friends'
      # @param [Hash] connection_options The options associated with
      #   the connection.
      def initialize(parent, connection_name, connection_options)
        @parent = parent
        @connection_name = connection_name
        @connection_options = connection_options
      end

      # Returns a scope for all of the data which is part of this
      # connection.
      #
      # @return [ConnectionScope]
      def all
        # TODO: Cache this value so that the subsequent loads are also
        # cached.
        ConnectionScope.new(self)
      end

      # Loads the data represented by this proxy given the scope. The
      # proxy itself doesn't cache any data. All the caching is done
      # on the scope itself.
      #
      # **Note:** This method should never be called
      # manually. Instead, using the various scope methods, and this
      # method will be called automatically.
      #
      # @param [ConnectionScope] scope
      # @return [Hash]
      def load(scope)
        data = parent.get("/#{connection_name}", scope.options)
        parse_data(data)
      end

      # Parses the resulting data from a API request for a
      # connection and returns the hash associated with it. This
      # method replaces all the data hashes with actual
      # {FacebookObject} objects.
      #
      # @param [Hash] data The data returned from the API call.
      # @return [Hash]
      def parse_data(data)
        data ||= {}
        data["data"] ||= []
        data["data"] = data["data"].collect do |raw_item|
          connection_class.new(raw_item)
        end

        data
      end

      # Returns the class associated with this connection.
      #
      # @return [Class]
      def connection_class
        Fogli.const_get(connection_options[:class])
      end
    end
  end
end
