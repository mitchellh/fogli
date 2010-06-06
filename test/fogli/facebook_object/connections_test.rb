require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class FacebookObjectConnectionsTest < Test::Unit::TestCase
  class FOCTestClass
    include Fogli::FacebookObject::Connections
  end

  setup do
    @klass = FOCTestClass
  end

  context "class methods" do
    context "defining connections" do
      teardown do
        @klass.connections.clear
      end

      should "be able to define a connection" do
        @klass.connection(:foo)
        assert @klass.connections.keys.include?(:foo)
      end

      should "be able to define multiple connections" do
        @klass.connection(:foo, :bar)
        assert @klass.connections.keys.include?(:foo)
        assert @klass.connections.keys.include?(:bar)
      end

      should "be able to define options" do
        @klass.connection(:foo, :bar => :baz)
        assert @klass.connections.keys.include?(:foo)
        assert_equal :baz, @klass.connections[:foo][:bar]
      end

      should "propagate connections" do
        @subklass = Class.new(@klass)
        @klass.connection :foo
        assert !@subklass.connections.keys.include?(:foo)
        @klass.propagate_connections(@subklass)
        assert @subklass.connections.keys.include?(:foo)
      end
    end
  end
end
