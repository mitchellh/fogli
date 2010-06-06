module Fogli
  class Photo < FacebookObject
    property :from, :tags, :name, :source, :height, :width,
             :link, :created_time

    connection :comments, :class => :Comment
  end
end
