module Fogli
  # Represents a _root_ facebook object, which is an object which is
  # queryable on the root of the graph domain, such as at
  # `http://graph.facebook.com/id`. This is a special case because
  # these objects support the hash-access method via the {[]} method
  # and also the {find} method.
  class RootFacebookObject < FacebookObject
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
    end

    # Override {FacebookGraph#get} to prepend object ID. When calling
    # {#get} on an instance of a root facebook object, its typically
    # to access a connection. To avoid repetition, we always prepend
    # the root object's ID.
    def get(url, *args)
      super("/#{id}#{url}", *args)
    end
  end
end
