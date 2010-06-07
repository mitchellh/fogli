require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject
  end

  context "properties and connections" do
    should "include the properties module" do
      assert @klass.included_modules.include?(Fogli::FacebookObject::Properties)
    end

    should "have an id property" do
      assert @klass.properties.keys.include?(:id)
    end

    should "have a updated_time property" do
      assert @klass.properties.keys.include?(:updated_time)
    end

    should "propagate properties to subclasses" do
      @subklass = Class.new(@klass)
      assert @subklass.properties.keys.include?(:id)
    end

    should "propagate connections to subclasses" do
      @klass.connection(:foo, :class => :bar)
      @subklass = Class.new(@klass)
      assert @subklass.connections.keys.include?(:foo)
      @klass.connections.clear
    end
  end

  context "finding" do
    setup do
      @klass.stubs(:get)
    end

    should "get the resource and populate the instance" do
      id = :foo
      data = { "id" => "22" }
      @klass.expects(:get).with("/#{id}").returns(data)
      result = @klass.find(id)
      assert_equal data["id"], result.id
    end
  end

  context "initialization" do
    should "be okay without any arguments" do
      assert_nothing_raised {
        @klass.new
      }
    end

    should "populate properties if data is given" do
      data = { "id" => "42" }
      instance = @klass.new(data)
      assert_equal data["id"], instance.id
    end
  end

  context "with an instance" do
    setup do
      @instance = @klass.new
    end

    [:get, :post, :delete].each do |method|
      should "prepend any #{method} requests with the ID" do
        id = "foo"
        RestClient.expects(method).with() do |url, other|
          assert url =~ /\/foo\/bar$/, "Invalid URL: #{url}"
          true
        end

        @instance.stubs(:id).returns(id)
        @instance.send(method, "/bar")
      end
    end
  end
end
