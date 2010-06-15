require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), %W[.. config])

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
  a = Fogli::Album.new
  a.name = "My Test Album"
  a.message = "My Test Message"
  a.profile = Fogli::User[:me]
  a.save
end
