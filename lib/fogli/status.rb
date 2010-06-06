module Fogli
  class Status < FacebookObject
    property :from, :message

    connection :comments, :class => :Comment
  end
end
