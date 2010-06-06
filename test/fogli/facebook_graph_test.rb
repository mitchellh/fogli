require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookGraphTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookGraph
  end

  context "httparty" do
    should "include HTTParty" do
      assert @klass.included_modules.include?(HTTParty)
    end
  end
end
