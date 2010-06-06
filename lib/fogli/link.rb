module Fogli
  class Link < RootFacebookObject
    property :from, :link, :name, :caption, :description,
             :message
  end
end
