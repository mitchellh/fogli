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
      def verify_options(data, options=nil)
        data ||= {}
        options ||= {}
        options[:valid_keys] ||= options[:default].keys if options[:default]

        # Merge in the default data and remove any invalid keys if
        # valid keys are specified.
        ops = options[:default] || {}
        ops.merge!(data)
        ops.reject! { |k,v| !options[:valid_keys].include?(k) } if options[:valid_keys]

        if options[:required_keys]
          required = ops.reject { |k,v| !options[:required_keys].include?(k) || v.nil? }
          raise ArgumentError.new("Missing required options: #{options[:required_keys].inspect}") if required.length != options[:required_keys].length
        end

        ops
      end
    end
  end
end
