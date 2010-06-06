module Fogli
  class Link < FacebookObject
    property :from, :link, :name, :caption, :description,
             :message

    connection :comments, :class => :Comment
  end
end
