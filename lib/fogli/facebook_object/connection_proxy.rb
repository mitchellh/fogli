module Fogli
  class FacebookObject < FacebookGraph
    # The proxy object which sits between a facebook object and one of
    # it's connections. This connection proxy only represents
    # connections which are a "has many" type, which happens to be
    # every connection represented by the Facebook Graph except for
    # "picture" which is handled as a special case.
    class ConnectionProxy
      include Enumerable

      attr_reader :parent
      attr_reader :connection_name
      attr_reader :connection_options
      attr_reader :data

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

      # Loads the data represented by this proxy. This method handles
      # making the request as well as initializing the data on the
      # connection class.
      def load!
        raw = parent.get("/#{connection_name}")

        @data = []
        if raw && raw["data"]
          @data = raw["data"].collect do |raw_item|
            connection_class(raw_item).new(raw_item)
          end
        end

        self
      end

      # Returns the class associated with this connection.
      #
      # @param [Hash] raw The raw data associated with the
      #   current item. This data is used for `:dynamic` class lookup
      #   and ignored if a class was statically specified in the
      #   connection options.
      # @return [Class]
      def connection_class(raw)
        klass = connection_options[:class]
        if klass == :dynamic
          # Dynamic, figure it out based on the "type" given by FB
          klass = raw["type"].capitalize.to_sym
        end

        Fogli.const_get(klass)
      end
    end
  end
end
