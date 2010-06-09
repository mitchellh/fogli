module Fogli
  # A dynamic object finder. Given any ID, this class's {find} method
  # will return the proper class, such as {User} or {Post}. This is
  # done by requesting the meta-data associated with the object, which
  # causes more-than-usual data to be returned from Facebook, but is
  # the cost to pay for dynamic lookup.
  class Dynamic < FacebookGraph
    class << self
      # Find an object and dynamically determine its type, returning
      # the proper instantiated type. This is the only find method
      # which is **not** lazy loaded, since the type must be known
      # before an object is returned!
      #
      # The arguments to this method are the same as
      # {FacebookObject.find}.
      def find(*ids)
        params = {}
        params = ids.pop if ids.last.is_a?(Hash)
        params[:ids] = ids.join(",")
        params[:metadata] = 1

        data = get("/", params)
        results = ids.collect do |id|
          raw = data[id.to_s]
          class_for_data(raw).new(raw.merge(:_loaded => true))
        end

        ids.length == 1 ? results.first : results
      end

      # Returns the class for the given raw data. If the type cannot
      # be determined, then a {FacebookObject} is returned.
      #
      # @param [Hash] raw The raw data.
      # @return [Class]
      def class_for_data(raw)
        Fogli.const_get(raw["type"].capitalize.to_sym)
      rescue Exception, NoMethodError
        FacebookObject
      end
    end
  end
end
