module Fogli
  class Event < FacebookObject
    property :owner, :name, :description, :start_time, :end_time, :location,
             :venue, :privacy

    connection :feed, :class => :Post
    connection :noreply, :maybe, :invited, :attending, :declined, :class => :User
  end
end
