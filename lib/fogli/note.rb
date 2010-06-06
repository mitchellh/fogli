module Fogli
  class Note < RootFacebookObject
    property :from, :subject, :message, :created_time
  end
end
