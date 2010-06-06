module Fogli
  class Album < FacebookObject
    property :from, :name, :description, :location, :link, :count, :created_time

    connection :photos, :class => :Photo
    connection :comments, :class => :Comment
  end
end
