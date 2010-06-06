module Fogli
  class Link < RootFacebookObject
    property :from, :link, :name, :caption, :description,
             :message

    connection :comments, :class => :Comment
  end
end
