require 'rubygems'
require 'sinatra'

# Make sure we load the most recent fogli that this is packaged with
# if its available.
$:.unshift(File.join(File.dirname(__FILE__), *%W[.. .. lib]))
require 'fogli'

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
# IMPORTANT: Set your app configuration details here:
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
Fogli.client_id = "132862110062471"
Fogli.client_secret = "3f2f371b6f01c449eb3bcfc841b1b9c1"

# No need to edit this:
Fogli.redirect_uri = "http://localhost:4567/verify"

get "/" do
  # Authorize the user so we can get an access token
  redirect Fogli::OAuth.authorize(:scope => "email")
end

get "/verify" do
  # Get and store the access token, then print out their user
  # information to verify it worked
  Fogli.access_token = Fogli::OAuth.access_token(:code => params[:code])

  # Output authorized information to verify it worked
  Fogli::User[:me].email
end
