module Fogli
  class Status < RootFacebookObject
    property :from, :message

    connection :comments, :class => :Comment
  end
end
