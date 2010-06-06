module Fogli
  class Note < FacebookObject
    property :from, :subject, :message, :created_time

    connection :comments, :class => :Comment
  end
end
