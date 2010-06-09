require 'fogli/facebook_object/properties'
require 'fogli/facebook_object/connections'

module Fogli
  # Represents any facebook object. This exposes the common
  # abstractions used by every other facebook object such as the
  # concept of properties and connections.
  #
  # # Finding an Object
  #
  # To find any Facebook object, use the {find} method. The find
  # method is _lazy_, meaning that it doesn't actually make the HTTP
  # request to Facebook then, but instead defers the call to when the
  # first property is accessed.
  #
  #     user = Fogli::User["mitchellh"]
  #     user.first_name # HTTP request is made here
  #     user.last_name  # Loaded already so not request is made
  #
  # # Finding an Object, but Selecting Specific Fields
  #
  # To conserve bandwidth and lower transfer time, you can select only
  # specific fields of an object. An example is shown below:
  #
  #     user = Fogli::User.find("mitchellh", :fields => [:first_name, :last_name])
  #     user.first_name # "Mitchell"
  #     user.link       # nil, since we didn't request it
  #
  # # Checking if an Object Exists
  #
  # Since objects are lazy loaded, you can't check the return value of
  # {find} to see if an object exists. Instead, you must use the
  # dedicated {exist?} or {#exist?} methods. The difference is
  # outlined below:
  #
  # * {#exist?} loads all of the data associated with an instance to
  #   check for existence, so that the data is ready to go on a property
  #   access.
  # * {exist?} only loads the ID of an object, which uses less
  #   bandwidth and has less overhead associated with it. This is ideal
  #   for only checking if an object exists, but not caring about the
  #   properties.
  #
  class FacebookObject < FacebookGraph
    autoload :ConnectionProxy, 'fogli/facebook_object/connection_proxy'
    autoload :ConnectionScope, 'fogli/facebook_object/connection_scope'
    autoload :ScopeMethods, 'fogli/facebook_object/scope_methods'

    include Properties
    include Connections
    extend Util::Options

    # The fields which this object is restricted to. If empty, returns
    # the default fields (Facebook's choice)
    attr_reader :_fields

    # If non-nil, then represents the collection of objects which are
    # to be queried in a single request.
    attr_reader :_collection

    # Every facebook object has an id and typically an updated time
    # (if authorized)
    property :id, :updated_time

    class << self
      # Finds the facebook object associated with the given `id`. The
      # object is **not loaded** until the first property access. To
      # check if an object exists, you can call {#exist?} on the
      # object itself, which will proceed to load all the relevant
      # properties as well. Or, you can use the class-level {exist?}
      # if you only care about if the object exists, but not about
      # it's properties.
      #
      # For examples on how to use this method, please view the
      # documentation for the entire {FacebookObject} class.
      #
      # @param [String] id ID of the object
      #   above.
      # @param [Hash] options Options such as `fields`.
      # @return [FacebookObject]
      def find(*ids)
        ids.flatten!

        options = ids.pop if ids.last.is_a?(Hash)
        options = verify_options(options, :valid_keys => [:fields])

        result = ids.inject([]) do |collection, id|
          data = { :id => id, :_loaded => false, :_collection => collection }
          data[:_fields] = []
          data[:_fields] << [options[:fields]] if options[:fields]
          data[:_fields].flatten!

          # Initialize the object with the loaded flag off and with the
          # ID, so that the object is lazy loaded on first use.
          collection << new(data)
        end

        # If we're only requesting 1 ID then just return the object,
        # otherwise return an array of objects
        result.length == 1 ? result.first : result
      end
      alias :[] :find

      # Checks if the given object exists within the Facebook
      # Graph. This method will return `true` or `false` depending on
      # if the object exists. Calling {exist?} is more efficient than
      # calling {#exist?} if you only care about the existence of an
      # object, since {exist?} does not load all the properties
      # associated with an object, which lowers bandwidth and network
      # time.
      #
      # @param [String] id ID of the object
      # @return [Boolean]
      def exist?(id)
        get("/#{id}", :fields => "id")
        true
      rescue Fogli::Exception
        false
      end

      # Propagates the properties and connections to any subclasses
      # which inherit from FacebookObject. This method is called
      # automatically by Ruby.
      def inherited(subclass)
        super

        propagate_properties(subclass)
        propagate_connections(subclass)
      end
    end

    # Initialize a facebook object. If given some data, it will
    # attempt to populate the various properties with the given data.
    #
    # @param [Hash] data The data for this object.
    def initialize(data=nil)
      data ||= {}

      # Pull out any "special" values which may be in the data hash
      @_loaded = !!data.delete(:_loaded)
      @_fields = data.delete(:_fields) || []
      @_fields.collect! { |f| f.to_sym }
      @_collection = data.delete(:_collection) || [self]

      populate_properties(data) if !data.empty?
    end

    # Returns a boolean noting if the object's data has been loaded
    # yet. {FacebookObject}s are loaded on demand when the first
    # attribute is accessed.
    #
    # @return [Boolean]
    def loaded?
      !!@_loaded
    end

    # Marks this object as loaded. Don't call this unless you know
    # what you're doing.
    def loaded!
      @_loaded = true
    end

    # Loads the data from Facebook. This is typically called once on
    # first access of a property.
    def load!
      params = {
        :ids => _collection.collect { |o| o.id }.join(","),
        :_no_id => true
      }
      params[:fields] = _fields.join(",") if !_fields.empty?

      Fogli.logger.info("Fogli Load: #{self.class}[#{params[:ids]}] (object_id: #{__id__})") if Fogli.logger

      data = get("/", params)

      _collection.each do |object|
        object.populate_properties(data[object.id] || {})
        object.loaded!
      end

      self
    end

    # Checks if the given object exists. Since these objects are lazy
    # loaded, a direct {find} call doesn't check the existence of an
    # object. By calling this method, it forces the data to load and
    # also returns `true` or `false` depending on if the object exists
    # or not.
    #
    # If you only care about the existence of an object and not it's
    # data, use {exist?} instead, which is more efficient.
    #
    # @return [Boolean]
    def exist?
      load!
      true
    rescue Fogli::Exception
      false
    end

    # Returns the resouce URI associated with this object. For
    # example, if the ID of this object is "george" then the URL
    # returned will be this:
    #
    #     http://graph.facebook.com/george
    #
    # @return [String]
    def resource_uri
      "http://#{FacebookGraph::GRAPH_DOMAIN}/#{id}"
    end

    # Returns the URL for the picture associated with this object.
    # This URL can be used in any HTML <img /> tag to display the
    # image which represents this object.
    #
    # @return [String]
    def picture
      "#{resource_uri}/picture"
    end

    # Override the read property method to call {#load!} if this
    # object hasn't been loaded yet.
    alias_method :read_property_original, :read_property
    def read_property(name)
      if name.to_sym != :id
        if !loaded?
          load!
        elsif Fogli.logger
          # Cache hit, log it if enabled
          Fogli.logger.info("Fogli Cache: #{self.class}[#{id}].#{name} (object_id: #{__id__})")
        end
      end

      read_property_original(name)
    end

    # Delete an object. This always requires an access token. If you
    # do not yet have an access token, you must get one via {OAuth}.
    def delete
      # Although Facebook supposedly supports DELETE requests, we use
      # their POST method since the rest client seems to have problems
      # with DELETE requests.
      post(:method => :delete)
    end

    # Override request methods to prepend object ID. When making a
    # request on an instance of a facebook object, its typically
    # to access a connection. To avoid repetition, we always prepend
    # the root object's ID.
    [:get, :post].each do |method|
      define_method(method) do |*args|
        url = ""
        url = "/#{id}" if !args.last.is_a?(Hash) || !args.last.delete(:_no_id)
        url += args.shift.to_s if !args[0].is_a?(Hash)
        super(url, *args)
      end
    end

    # Customize the inspect method to pretty print Facebook objects
    # and their associated properties and connections.
    def inspect
      values = []
      self.class.properties.each do |name, options|
        value = read_property(name)
        values << "#{name.inspect}=#{value.inspect}"
      end

      self.class.connections.each do |name, options|
        values.push("#{name.inspect}=...")
      end

      "#<#{self.class} #{values.sort.join(", ")}>".strip
    end
  end
end
