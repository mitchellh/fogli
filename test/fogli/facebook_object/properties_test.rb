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
        @property_klass = Class.new
        @property_klass.send(:include, Fogli::FacebookObject::Properties)
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

      should "create a readonly method by default" do
        @property_klass.property(:baz)
        assert @property_klass.new.respond_to?(:baz)
        assert !@property_klass.new.respond_to?(:baz=)
      end

      should "be able to define writable properties" do
        @property_klass.property(:baz, :writer => true)
        assert @property_klass.new.respond_to?(:baz=)
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
      @klass.property :name, :writer => true
      @instance = @klass.new
    end

    teardown do
      @klass.properties.clear
    end

    context "new/existing record" do
      should "be a new record by default" do
        assert @instance.new_record?
      end

      should "be an existing record if properties are populated" do
        @instance.populate_properties(:id => :foo)
        assert !@instance.new_record?
      end
    end

    context "populating and reading properties" do
      should "set the properties based on the hash data" do
        @instance.populate_properties({"id" => "foo"})
        assert_equal "foo", @instance.id
      end

      should "set the properties based on the hash data [symbol]" do
        @instance.populate_properties({:id => "foo"})
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

    context "writing properties" do
      should "write and store the properties" do
        name = :foo
        assert_nil @instance.name
        @instance.name = name
        assert_equal name, @instance.name
      end

      should "not allow writing of existing records" do
        @instance.populate_properties(:id => :foo)
        assert_raises(Fogli::ReadOnlyException) {
          @instance.name = :foo
        }
      end

      should "turn other FacebookObjects into their respective IDs" do
        @object = Fogli::FacebookObject.new(:id => :foo)
        @instance.name = @object
        assert_equal @object.id, @instance.name
      end
    end
  end
end
