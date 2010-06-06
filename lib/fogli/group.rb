module Fogli
  class Group < FacebookObject
    property :owner, :name, :description, :link, :venue, :privacy

    connection :feed
    connection :members, :class => :User
  end
end
