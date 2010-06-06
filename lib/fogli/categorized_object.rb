module Fogli
  # A categorized object. In addition to simple objects such as
  # {NamedObject}s, Facebook also has simple objects which only have a
  # name and category in addition to an ID. This object represents
  # such an object.
  class CategorizedObject < NamedObject
    property :category
  end
end
