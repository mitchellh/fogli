module Fogli
  class FacebookObject < FacebookGraph
    # Includable module which has the scope methods to properly
    # instantiate a {ConnectionScope}.
    module ScopeMethods
      # The various scoping types. Each method takes a single value
      # associated with it, which is used to build up a new scope.
      [:limit, :offset, :until, :since].each do |scope|
        define_method(scope) do |value|
          ConnectionScope.new(*_scope_initializer_args(scope, value))
        end
      end

      # Scope the connection by the fields you're interested in. By
      # default, the connection will load all the possible fields for
      # the connection, which can result in a fairly large overhead if
      # you're only interested in the `first_name`, for example.
      #
      # The parameter to this method can be almost anything which can
      # intuitively be converted down to either a string or
      # array. Some example uses follow (admittingly some of these are
      # a bit pathological, but they're meant to showcase the
      # flexibility of the method):
      #
      #     fields("name,birthday,last_name")
      #     fields(:name, :birthday, :last_name)
      #     fields([:name, "birthday"], :last_name)
      #     fields("name,birthday", ["last_name"])
      #
      def fields(*fields)
        ConnectionScope.new(*_scope_initializer_args(:fields, fields.flatten.join(",")))
      end

      # Returns the proper set of arguments to send to the
      # {ConnectionScope} initializer given the scope and value.
      #
      # @param [Symbol] scope The scope option.
      # @param [Object] value The value for the scope.
      # @return [Array]
      def _scope_initializer_args(scope, value)
        if self.is_a?(ConnectionScope)
          [proxy, options.merge(scope => value)]
        else
          [self, {scope => value}]
        end
      end
    end
  end
end
