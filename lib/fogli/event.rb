module Fogli
  class Event < FacebookObject
    property :owner, :name, :description, :start_time, :end_time, :location,
             :venue, :privacy

    connection :feed, :class => :Post
    conncetion :noreply, :maybe, :invited, :attending, :declined, :class => :User
  end
end
