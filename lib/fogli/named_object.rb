module Fogli
  # A simple, named object. Many things in Facebook are associated
  # with an ID but simply have a name. This object represents such an
  # item.
  class NamedObject < FacebookObject
    property :name
  end
end
