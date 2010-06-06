module Fogli
  class Event < RootFacebookObject
    property :owner, :name, :description, :start_time, :end_time, :location,
             :venue, :privacy

    connection :feed
    conncetion :noreply, :maybe, :invited, :attending, :declined, :class => :User
  end
end
