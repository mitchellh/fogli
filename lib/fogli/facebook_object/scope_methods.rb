module Fogli
  class FacebookObject < FacebookGraph
    # Includable module which has the scope methods to properly
    # instantiate a {ConnectionScope}.
    module ScopeMethods
      # The various scoping types. Each method takes a single value
      # associated with it, which is used to build up a new scope.
      [:limit, :offset, :until, :since].each do |scope|
        define_method(scope) do |value|
          args = if self.is_a?(ConnectionScope)
            [proxy, options.merge(scope => value)]
          else
            [self, {scope => value}]
          end

          ConnectionScope.new(*args)
        end
      end
    end
  end
end
