module Fogli
  class Group < RootFacebookObject
    property :owner, :name, :description, :link, :venue, :privacy

    connection :feed
    connection :members, :class => :User
  end
end
