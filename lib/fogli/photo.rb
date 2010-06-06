module Fogli
  class Photo < RootFacebookObject
    property :from, :tags, :name, :source, :height, :width,
             :link, :created_time

    connection :comments, :class => :Comment
  end
end
