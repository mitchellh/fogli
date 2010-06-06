require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject
  end

  context "properties" do
    should "have an id property" do
      assert @klass.properties.keys.include?(:id)
    end

    context "defining properties" do
      class PropertyTestClass < Fogli::FacebookObject; end

      setup do
        @property_klass = PropertyTestClass
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

      should "inherit properties" do
        @property_klass.property :foo
        class SubPropertyTestClass < PropertyTestClass; end
        assert SubPropertyTestClass.properties.keys.include?(:foo)
      end
    end
  end

  context "with an instance" do
    setup do
      @instance = @klass.new
    end

    context "populating properties" do
      should "set the properties based on the hash data" do
        @instance.populate_properties({"id" => "foo"})
        assert_equal "foo", @instance.id
      end
    end
  end
end
