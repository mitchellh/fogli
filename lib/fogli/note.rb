module Fogli
  class Note < RootFacebookObject
    property :from, :subject, :message, :created_time

    connection :comments, :class => :Comment
  end
end
