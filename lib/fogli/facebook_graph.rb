require 'cgi'
require 'restclient'
require 'json'

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

    class << self
      # Override default HTTParty behavior to go through our request
      # method to make sure that the access token is properly set if
      # needed.
      [:get, :post, :delete].each do |method|
        # A requester, where the arguments go through the {request}
        # method, which handles automatically adding the
        # {Fogli.access_token} if it is specified, and also handles
        # the URL relative to the given path.
        define_method(method) do |*args|
          request(method, *args)
        end

        # A raw requester, which just directly requests with the given
        # arguments.
        define_method("raw_#{method}".to_sym) do |*args|
          error_check { RestClient.send(method, *args) }
        end
      end

      # Issues the specified request type with the given URL and
      # options. This method will inject the Facebook `access_token`
      # if it is available, and will properly change the method to
      # "https" if needed.
      def request(type, url, params=nil)
        params ||= {}

        if Fogli.access_token
          params ||= {}
          params.merge!(:access_token => Fogli.access_token)
        end

        method = "http"
        method = "https" if params[:access_token]

        url = "#{method}://#{GRAPH_DOMAIN}#{url}"
        if !params.empty? && [:get, :delete].include?(type)
          # For GET and DELETE, we're responsible for appending any
          # query parameters onto the end of the URL
          params = params.inject([]) do |acc, data|
            k, v = data
            acc << "#{k}=#{CGI.escape(v.to_s)}"
            acc
          end

          url += "?#{params.join("&")}"
          params = {}
        end

        error_check { RestClient.send(type, url, params) }
      end

      # Yields a block, checking for any errors in a request. If no
      # errors are detected, decodes JSON and returns the result.
      def error_check
        response = begin
          yield
        rescue RestClient::Exception => e
          e.response
        end

        data = parse_response(response)
        if data.is_a?(Hash) && data["error"]
          data = data["error"]
          raise Exception.new(data["type"], data["message"])
        end

        data
      rescue NoMethodError
        data
      end

      # Parses a response depending on the content type it sent back.
      def parse_response(response)
        type = response.headers[:content_type]
        return response.body if type.include?("text/plain")
        return JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
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
