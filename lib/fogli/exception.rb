module Fogli
  # An exception from a call to the Facebook Graph API. This will
  # always contain the exception type and the message given.
  class Exception < ::Exception
    attr_reader :type
    attr_reader :message

    def initialize(type, message)
      @type = type
      @message = "[#{type}] #{message}"

      super()
    end
  end
end
