module Fogli
  class Event < FacebookObject
    property :owner, :name, :description, :start_time, :end_time, :location,
             :venue, :privacy

    connection :feed, :class => :Post
    connection :noreply, :maybe, :invited, :attending, :declined, :class => :User

    # Mark current user as attending a given event.
    #
    # This method requires a valid `access_token` to be set on
    # {Fogli}.
    def attend!
      post("/attending")
    end

    # Mark current user as maybe attending.
    #
    # This method requires a valid `access_token` to be set on
    # {Fogli}.
    def maybe!
      post("/maybe")
    end

    # Mark current user as declining an event.
    #
    # This method requires a valid `access_token` to be set on
    # {Fogli}.
    def decline!
      post("/declined")
    end
  end
end
