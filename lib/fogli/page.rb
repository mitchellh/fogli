module Fogli
  class Page < FacebookObject
    property :name, :category

    connection :feed, :tagged
    connection :links, :class => :Link
    connection :photos, :class => :Photo
    connection :groups, :class => :Group
    connection :albums, :class => :Album
    connection :statuses, :class => :Status
    connection :videos, :class => :Video
    connection :notes, :class => :Note
    connection :posts, :class => :Post
    connection :events, :class => :Event
  end
end
