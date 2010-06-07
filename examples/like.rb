# "Like" Example
#
# This example shows how to "like" or "unlike" a post on Facebook.
$:.unshift(File.join(File.dirname(__FILE__), *%W[.. lib]))
require 'fogli'
require 'sinatra'

# Set the static configuration
Fogli.client_id = "132862110062471"
Fogli.client_secret = "3f2f371b6f01c449eb3bcfc841b1b9c1"
Fogli.redirect_uri = "http://localhost:4567/verify"

get "/" do
  # Authorize the user so we can get an access token
  redirect Fogli::OAuth.authorize(:scope => "read_stream,publish_stream")
end

get "/verify" do
  # Get and store the access token, then print out their user
  # information to verify it worked
  Fogli.access_token = Fogli::OAuth.access_token(:code => params[:code])

  # Output authorized information to verify it worked
  Fogli::User[:me].feed[0].like!.inspect
end