module Fogli
  class Post < RootFacebookObject
    property :from, :to, :message, :link, :name, :caption, :description,
             :source, :icon, :attribution, :actions, :likes, :created_time
  end
end
