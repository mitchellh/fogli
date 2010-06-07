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
        @_loaded = false
      end

      # Returns a boolean value denoting whether or not this
      # connection has been loaded yet.
      def loaded?
        !!@_loaded
      end

      # Loads the data represented by this proxy. This method handles
      # making the request as well as initializing the data on the
      # connection class.
      def load!
        raw = if parent._fields.include?(connection_name.to_sym)
          # This is marked for eager loading from the parent, so load
          # the parent if we need to
          parent.load! if !parent.loaded?
          parent._raw[connection_name.to_s]
        else
          # Otherwise load the data via HTTP
          parent.get("/#{connection_name}")
        end

        @data = []
        if raw && raw["data"]
          @data = raw["data"].collect do |raw_item|
            connection_class(raw_item).new(raw_item)
          end
        end

        @_loaded = true
        self
      end

      # Access a specific item in the connection.
      #
      # @param [Integer] index
      # @return [Object]
      def [](index)
        load! if !loaded?
        data[index]
      end

      # Iterate over every object which is part of this
      # connection. {ConnectionProxy} also includes the `Enumerable`
      # module so many other methods are available, just look at the
      # standard library documentation for `Enumerable`.
      def each(&block)
        load! if !loaded?
        data.each(&block)
      end

      # Returns the class associated with this connection.
      #
      # @param [Hash] raw The raw data associated with the
      #   current item. This data is used for `:dynamic` class lookup
      #   and ignored if a class was statically specified in the
      #   connection options.
      # @return [Class]
      def connection_class(raw)
        Fogli.const_get(connection_options[:class])
      end
    end
  end
end
