module Fogli
  class Album < RootFacebookObject
    property :from, :name, :description, :location, :link, :count, :created_time

    connection :photos, :class => :Photo
  end
end
