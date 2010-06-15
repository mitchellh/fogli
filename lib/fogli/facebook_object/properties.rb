module Fogli
  class FacebookObject < FacebookGraph
    # Allows for properties to be set on an object. A property is
    # accessible instance data which is parsed from the JSON data blob
    # which is returned by Graph API calls.
    module Properties
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Defines a property on the object. These properties map
        # directly to keys in the returned JSON from the Facebook
        # Graph API.
        def property(*names)
          options = names.last
          options = {} if !options.kind_of?(Hash)

          names.each do |name|
            next if name.kind_of?(Hash)
            name = name.to_s.downcase.to_sym
            properties[name] = options

            # Create a method for reading the property.
            define_method(name) { read_property(name) }

            if options[:writer]
              # Create a method for writing the property if specified
              define_method("#{name}=".to_sym) { |value| write_property(name, value) }
            end
          end
        end

        # Returns the properties associated with this facebook
        # object.
        #
        # @return [Hash]
        def properties
          @_properties ||= {}
        end

        # Propagates properties to another class. This is used
        # internally for making sure that subclasses get all the
        # properties associated with the parent classes.
        def propagate_properties(klass)
          properties.each { |n, o| klass.property(n, o) }
        end
      end

      # Populates the properties with the given hash of data. This
      # method also handles parsing non-primitive data such as other
      # facebook objects.
      def populate_properties(data)
        # Clear old values and mark as an existing record
        property_values.clear
        @_existing_record = true

        self.class.properties.keys.each do |name|
          # Try both the string and symbol lookup to get the item
          # associated with a key
          item = data[name.to_s] || data [name]

          if item.is_a?(Hash)
            # For now, assume its a NamedObject. In the future, we'll be
            # more careful.
            item = NamedObject.new(item.merge(:_loaded => true))
          end

          property_values[name] = item
        end

        self
      end

      # Returns a boolean true/false depending on if this instance
      # represents a new or existing record.
      #
      # @return [Boolean]
      def new_record?
        !@_existing_record
      end

      # Reads a property.
      #
      # @param [Symbol] name The name of the property to read.
      # @return [Object]
      def read_property(name)
        value = property_values[name]
        value = value.name if value.is_a?(NamedObject)
        value
      end

      # Writes a property
      #
      # @param [Symbol] name The name of the property to write.
      # @param [Object] value The value to associate with the property.
      def write_property(name, value)
        raise ReadOnlyException.new if !new_record?
        value = value.id if value.is_a?(FacebookObject)
        property_values[name] = value
      end

      # Stores the values of the variables properties
      #
      # @return [Hash]
      def property_values
        @_property_values ||= {}
      end
    end
  end
end
