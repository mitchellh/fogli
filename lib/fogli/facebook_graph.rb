module Fogli
  # The most basic level access to the Facebook Graph. This class only
  # has access to the `get`, `post`, etc. methods to query the
  # Facebook Graph directly. This class is used by every other class
  # to access the graph. This class also will automatically insert the
  # Facebook `access_token` if it has been specified, and handles
  # changing the HTTP method to HTTPS in that case.
  #
  # **Note:** Most users should never have to use this class
  # directly. Instead, use one of the models, such as {User}, to
  # access your data.
  #
  # # Requesting Data
  #
  # Getting data from the Facebook graph is simple:
  #
  #     Fogli::FacebookGraph.get("/mitchellh")
  #
  # If you have an access token, {FacebookGraph} will add it to the
  # query string without you having to do anything:
  #
  #     Fogli.access_token = "..."
  #     Fogli::FacebookGraph.get("/me")
  #
  class FacebookGraph
    GRAPH_DOMAIN = "graph.facebook.com"
    include HTTParty

    class << self
      # Override default HTTParty behavior to go through our request
      # method to make sure that the access token is properly set if
      # needed.
      [:get, :post, :delete].each do |method|
        alias_method "#{method}_original".to_sym, method

        define_method(method) do |*args|
          request(method, *args)
        end
      end

      # Issues the specified request type with the given URL and
      # options. This method will inject the Facebook `access_token`
      # if it is available, and will properly change the method to
      # "https" if needed.
      def request(type, url, options=nil)
        options ||= {}

        if Fogli.access_token
          options[:query] ||= {}
          options[:query].merge!(:access_token => Fogli.access_token)
        end

        method = "http"
        method = "https" if options && options[:query] && options[:query][:access_token]

        original = "#{type}_original".to_sym
        error_check(send(original, "#{method}://#{GRAPH_DOMAIN}#{url}", options))
      end

      # Checks a response from the Graph API for any errors, and
      # raises an {Exception} if any are found. If no errors are
      # found, simply returns the response back.
      def error_check(response)
        if response["error"]
          data = response["error"]
          raise Exception.new(data["type"], data["message"])
        end

        response
      rescue NoMethodError
        response
      end
    end

    # Shortcut methods to access the class-level methods.
    [:get, :post, :delete].each do |method|
      define_method(method) do |*args|
        self.class.send(method, *args)
      end
    end
  end
end
