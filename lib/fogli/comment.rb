module Fogli
  class Comment < RootFacebookObject
    property :from, :message, :created_time
  end
end
