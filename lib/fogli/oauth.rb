require 'cgi'

module Fogli
  # Handles OAuth authorization with Facebook to obtain an access key
  # which can then be used to retrieve authorized data via the
  # Facebook Open Graph API.
  #
  # # Requesting an Access Token
  #
  # Requesting an access token is a multi-step process:
  #
  # 1. Redirect the user to an authorization URL on the Facebook
  #    domain.
  # 2. After authorizing, Facebook redirects the user back to your
  #    domain, with a verification string as the `code` GET parameter.
  # 3. Request the access token from Facebook using the `code` GET
  #    parameter and the client ID and secret key given by Facebook
  #    during application creation.
  #
  # Fogli simplifies this into two separate API calls:
  #
  # 1. First call {authorize} to get the authorization URL.
  # 2. Call {access_token} to get the access token.
  #
  # # Persisting an Access Token
  #
  # After retrieving an access token, it should be persisted into a
  # cookie or some sort of session store. On subsequent requests, set
  # the access token on the {Fogli} object:
  #
  #     Fogli.access_token = cookies[:access_token]
  #
  # Fogli will then automatically use the access token on all API
  # requests to retrieve authorized data.
  class OAuth < FacebookGraph
    AUTHORIZE_URI = "http://graph.facebook.com/oauth/authorize?client_id=%s&redirect_uri=%s"

    # Returns the authorization URL to redirect the user to in order
    # to get an access token. This method takes a hash as its sole
    # argument, and has the following possible keys:
    #
    # * `:redirect_uri` (**required**) - The URI to redirect to after
    #   the user authorizes. This URI will be given a single parameter
    #   `code` as a GET variable. This should be passed into
    #   {access_token} to finally retrieve the access token.
    # * `:client_id` (optional) - The client ID of your Facebook
    #   application
    #
    # @param [Hash] options Described above.
    # @return [String] The authorization URL to redirect the user to.
    def self.authorize(options)
      options = {
        :client_id => Fogli.client_id,
        :redirect_uri => nil
      }.merge(options)

      # TODO: Raise exception if client_id or redirect_uri is nil
      AUTHORIZE_URI % [options[:client_id], CGI.escape(options[:redirect_uri])]
    end

    # Exchanges a verfication code for an access token. After
    # redirecting a user to the {authorize} URL, the user is
    # redirected back with the `code` GET parameter. This parameter
    # along with the `redirect_uri` should get passed into this
    # method, which will then return the access token. The possible
    # keys for the arguments hash are as follows:
    #
    # * `:redirect_uri` (**required**) - The URI which the user was
    #   redirected to with the `code` param.
    # * `:code` (**required**) - The code which was given as a GET
    #   param by facebook.
    # * `:client_id` (optional) - The client ID of your facebook
    #   application. If this is not specified here, it must be set via
    #   `Fogli.client_id=`
    # * `:client_secret` (optional) - The client secret key of your
    #   facebook application. If this is not specified here, it must be
    #   set via `Fogli.client_secret=`.
    #
    # The return value is the access token. This token should be
    # persisted in a cookie or some other session store, so it can be
    # used on subsequent requests. The token can be set via
    # `Fogli.access_token=`, which will cause all API calls to use the
    # specified access token.
    #
    # @param [Hash] options Described above.
    # @return [String] Access token
    def self.access_token(options)
      options = {
        :client_id => Fogli.client_id,
        :client_secret => Fogli.client_secret,
        :redirect_uri => nil,
        :code => nil
      }.merge(options)

      # TODO: Raise exception if missing arguments
      get("/oauth/access_token", :query => options)
    end
  end
end
