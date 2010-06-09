module Fogli
  class Post < FacebookObject
    property :from, :to, :message, :link, :name, :caption, :description, :type,
             :source, :icon, :attribution, :actions, :likes, :created_time

    connection :comments, :class => :Comment

    # Like a post. This method requires authorization.
    def like!
      post("/likes")
    end

    # Unlike a post. This method requires authorization.
    def unlike!
      post("/likes", :method => :delete)
    end
  end
end
