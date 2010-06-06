module Fogli
  class Video < RootFacebookObject
    property :from, :message, :description, :length, :created_time
  end
end
