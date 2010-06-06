module Fogli
  module Util
    module Options
      # Verifies that an options hash has all the required keys and
      # also merges it with a defaults hash if given. This is an
      # internal helper method.
      #
      # @param [Hash] options
      # @param [Array] required Array of required keys.
      # @param [Hash] defaults
      # @return [Hash]
      def verify_options(options, required=nil, defaults=nil)
        ops = defaults.dup || {} rescue {}
        ops.merge!(options || {})

        if required
          unused = required.inject([]) do |acc, k|
            acc << k if !ops[k]
            acc
          end

          raise ArgumentError.new("Missing required options: #{unused.inspect}") if !unused.empty?
        end

        ops
      end
    end
  end
end
