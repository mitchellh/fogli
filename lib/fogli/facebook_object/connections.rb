module Fogli
  class FacebookObject < FacebookGraph
    # Represents connections on a Facebook Object. Connections are
    # relationships between data.
    module Connections
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Defines a connection on the object.
        def connection(*names)
          options = names.last
          options = {} if !options.kind_of?(Hash)

          raise ArgumentError.new("`:class` is required for a connection.") if !options[:class]

          names.each do |name|
            next if name.kind_of?(Hash)
            name = name.to_s.downcase.to_sym
            connections[name] = options

            # Create a method for reading the property.
            define_method(name) { read_connection(name) }
          end
        end

        # Returns the connections associated with this facebook
        # object.
        #
        # @return [Hash]
        def connections
          @_connections ||= {}
        end

        # Propagates connections to another class. This is used
        # internally for making sure that subclasses get all the
        # connections associated with the parent classes.
        def propagate_connections(klass)
          connections.each { |n, o| klass.connection(n, o) }
        end
      end

      def read_connection(name)
        connection_values[name]
      end

      def connection_values
        @_connection_values ||= Hash.new do |h,k|
          options = self.class.connections[k]
          require 'unroller'
          h[k] = ConnectionProxy.new(self, k, options)
        end
      end
    end
  end
end
