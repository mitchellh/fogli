module Fogli
  class FacebookObject < FacebookGraph
    # Represents a connection scope, which is just a scoped view of
    # data. Since Facebook connections often represent massive amounts
    # of data (e.g. a Facebook feed for a user often has thousands of
    # entries), it is unfeasible for Facebook to send all this data in
    # one request, or for a typical developer to want access to _all_
    # of this data. Facebook solves this problem by paginating the
    # data over several API calls. {ConnectionScope} allows developers
    # to scope the requests using various methods such as {#since},
    # {#until}, {#limit}, and {#offset}, hiding the need for
    # pagination from the developer.
    #
    # Scopes are defined by chaining methods together. An actual
    # request to Facebook is only made when the data load is
    # requested:
    #
    # 1. {#all}
    # 2. {#each}
    #
    # # Scoping a Connection
    #
    #     items = User["mitchellh"].feed.since("yesterday").limit(5).all
    #     items.each do |item|
    #        ...
    #     end
    #
    class ConnectionScope
      include ScopeMethods

      attr_reader :proxy
      attr_reader :options
      attr_reader :_data

      # Initializes a connection scope. The actual data associated
      # with the proxy is not actually loaded until it is accessed.
      #
      # @param [ConnectionProxy] proxy The {ConnectionProxy} which
      #   this scope belongs to.
      # @param [Hash] options The options built up to this point.
      def initialize(proxy, options=nil)
        @proxy = proxy
        @options = options || {}
        @_data = nil
      end

      # Evaluates the current scope and yields to the given block for
      # each item. This method automatically handles facebook's
      # pagination, so the developer need not worry about it.
      def each(&block)
        load! if !_data
        _data["data"].each(&block)
      end

      # Loads the next batch of data associated with this scope and
      # adds it to the data array.
      def load!
        @_data = proxy.load(self)
      end
    end
  end
end
