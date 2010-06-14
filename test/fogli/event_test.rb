require File.join(File.dirname(__FILE__), '..', 'test_helper')

class EventTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Event
    @instance = @klass.new
  end

  should "be able to attend an event" do
    @instance.expects(:post).with("/attending").once
    @instance.attend!
  end

  should "be able to 'maybe' an event" do
    @instance.expects(:post).with("/maybe").once
    @instance.maybe!
  end

  should "be able to decline an event" do
    @instance.expects(:post).with("/declined").once
    @instance.decline!
  end
end
