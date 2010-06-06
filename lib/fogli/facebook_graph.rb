module Fogli
  # The most basic level access to the Facebook Graph. This class only
  # has access to the `get`, `post`, etc. methods to query the
  # Facebook Graph directly. This class is used by every other class
  # to access the graph.
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
  class FacebookGraph
    GRAPH_DOMAIN = "graph.facebook.com"
    include HTTParty

    class << self
      alias_method :get_original, :get

      # Overriding HTTParty's `get` method to handle access
      # tokens.
      def get(url, options=nil)
        if Fogli.access_token
          options ||= {}
          options[:query] ||= {}
          options[:query].merge!(:access_token => Fogli.access_token)
        end

        method = "http"
        method = "https" if options && options[:query] && options[:query][:access_token]
        get_original("#{method}://#{GRAPH_DOMAIN}#{url}", options)
      end
    end
  end
end
