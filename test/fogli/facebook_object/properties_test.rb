require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class FacebookObjectPropertiesTest < Test::Unit::TestCase
  class FOPTestClass
    include Fogli::FacebookObject::Properties
  end

  setup do
    @klass = FOPTestClass
  end

  context "class methods" do
    context "defining properties" do
      setup do
        @property_klass = @klass
      end

      teardown do
        @property_klass.properties.clear
      end

      should "be able to define a property" do
        @property_klass.property(:foo)
        assert @property_klass.properties.keys.include?(:foo)
      end

      should "be able to define multiple properties" do
        @property_klass.property(:foo, :bar)
        assert @property_klass.properties.keys.include?(:foo)
        assert @property_klass.properties.keys.include?(:bar)
      end

      should "be able to define options" do
        @property_klass.property(:foo, :bar => :baz)
        assert @property_klass.properties.keys.include?(:foo)
        assert_equal :baz, @property_klass.properties[:foo][:bar]
      end

      should "propagate properties" do
        @subklass = Class.new(@property_klass)
        @property_klass.property :foo
        assert !@subklass.properties.keys.include?(:foo)
        @property_klass.propagate_properties(@subklass)
        assert @subklass.properties.keys.include?(:foo)
      end
    end
  end

  context "with an instance" do
    setup do
      @klass.property :id
      @instance = @klass.new
    end

    teardown do
      @klass.properties.clear
    end

    should "set the properties based on the hash data" do
      @instance.populate_properties({"id" => "foo"})
      assert_equal "foo", @instance.id
    end

    should "detect and store NamedObjects" do
      @instance.populate_properties({"id" => {"name" => "foo"}})
      assert @instance.property_values[:id].is_a?(Fogli::NamedObject)
    end

    should "read NamedObject's names when reading a property" do
      @instance.populate_properties({"id" => {"name" => "foo"}})
      assert_equal "foo", @instance.id
    end
  end
end
