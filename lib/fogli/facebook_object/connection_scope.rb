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
      include Enumerable

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

        i = 0
        while true
          # Sanity check to avoid nil accesses, although this should
          # never happen
          break if !_data || !_data[i]

          Fogli.logger.info("Fogli Cache: #{log_string(i)}") if Fogli.logger
          _data[i]["data"].each(&block)
          i += 1

          if i >= _data.length
            # Load the next page, but exit the loop if we're on the
            # last page.
            break if !load!
          end
        end
      end

      # Loads the next batch of data associated with this scope and
      # adds it to the data array.
      def load!
        result = if _data.nil?
          # We haven't loaded any of the data yet so start with the
          # first page.

          # Default the fields to be all fields of the parent
          @options[:fields] ||= proxy.parent.class.properties.keys.join(",")

          @_data = [proxy.load(self)]
          true
        else
          # We want to load the next page of the data, and append it
          # to the data array.
          next_page = _data.last["paging"]["next"] rescue nil
          _data << proxy.parse_data(FacebookGraph.raw_get(next_page)) if next_page
          !next_page.nil?
        end

        Fogli.logger.info("Load: #{log_string(_data.length)}") if Fogli.logger && result
        result
      end

      # Clears the data cache associated with this scope. This will
      # force a reload of the data on the next call and will remove
      # all references to any data items.
      def clear_cache
        @_data = nil
      end

      # Returns the common log string for a scope. This is used
      # internally for the logger output, if enabled.
      #
      # @return [String]
      def log_string(page)
        "#{proxy.parent.class}/#{proxy.connection_name} (page #{page}) (object_id: #{__id__})"
      end
    end
  end
end
