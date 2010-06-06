module Fogli
  class Event < RootFacebookObject
    property :owner, :name, :description, :start_time, :end_time, :location,
             :venue, :privacy
  end
end
