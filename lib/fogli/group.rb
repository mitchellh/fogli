module Fogli
  class Group < RootFacebookObject
    property :owner, :name, :description, :link, :venue, :privacy
  end
end
