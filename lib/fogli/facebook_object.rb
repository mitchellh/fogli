module Fogli
  # Represents any facebook object. This exposes the common
  # abstractions used by every other facebook object such as the
  # concept of properties and connections.
  class FacebookObject < FacebookGraph
    class << self
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
        end
      end

      # Returns the properties associated with this facebook
      # object.
      #
      # @return [Hash]
      def properties
        @_properties ||= {}
      end

      # Propagates properties to subclasses. This method makes sure
      # that subclasses of this class will inherit the properties as
      # well, which is expected.
      def inherited(subclass)
        super rescue NoMethodError

        # Just push all the properties down
        properties.each { |name| subclass.property(name) }
      end
    end

    # Every facebook object has an id and typically an updated time
    property :id, :updated_time

    # Populates the properties with the given hash of data. This
    # method also handles parsing non-primitive data such as other
    # facebook objects.
    def populate_properties(data)
      property_values.clear

      self.class.properties.keys.each do |name|
        item = data[name.to_s]

        if item.is_a?(Hash)
          # For now, assume its a NamedObject. In the future, we'll be
          # more careful.
          item = NamedObject.new.populate_properties(item)
        end

        property_values[name] = item
      end

      self
    end

    # Reads a property.
    def read_property(name)
      value = property_values[name]
      value = value.name if value.is_a?(NamedObject)
      value
    end

    # Stores the values of the variables properties
    def property_values
      @_property_values ||= {}
    end
  end
end
