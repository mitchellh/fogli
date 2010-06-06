module Fogli
  class Video < RootFacebookObject
    property :from, :message, :description, :length, :created_time

    connection :comments, :class => :Comment
  end
end
