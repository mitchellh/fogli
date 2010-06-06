begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
end

require File.join(File.dirname(__FILE__), '..', 'lib', 'fogli')
require 'contest'
require 'mocha'

class Test::Unit::TestCase
  # For any global helpers.
end
