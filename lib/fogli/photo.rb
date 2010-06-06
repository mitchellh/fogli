module Fogli
  class Photo < RootFacebookObject
    property :from, :tags, :name, :source, :height, :width,
             :link, :created_time
  end
end
