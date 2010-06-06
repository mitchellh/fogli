module Fogli
  # The most basic level access to the Facebook Graph. This class only
  # has access to the `get`, `post`, etc. methods to query the
  # Facebook Graph directly. This class is used by every other class
  # to access the graph.
  #
  # **Note:** Most users should never have to use this class
  # directly. Instead, use one of the models, such as {User}, to
  # access your data.
  #
  # # Requesting Data
  #
  # Getting data from the Facebook graph is simple:
  #
  #     Fogli::FacebookGraph.get("/mitchellh")
  #
  class FacebookGraph
    include HTTParty
    base_uri "graph.facebook.com"
  end
end
