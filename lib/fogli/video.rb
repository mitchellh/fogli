module Fogli
  class Video < FacebookObject
    property :from, :message, :description, :length, :created_time

    connection :comments, :class => :Comment
  end
end
