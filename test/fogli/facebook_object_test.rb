require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject
  end

  context "class methods" do
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

      should "return an unloaded object immediately" do
        result = @klass.find(:foo)
        assert !result.loaded?
        assert_equal :foo, result.id
      end
    end

    context "existence checking" do
      should "only get the 'id' field" do
        id = :foo
        @klass.expects(:get).with("/#{id}", :fields => "id").once
        assert @klass.exist?(id)
      end

      should "return false if an exception is raised" do
        @klass.expects(:get).raises(Fogli::Exception.new("foo", "bar"))
        assert !@klass.exist?(:foo)
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

    context "loading" do
      setup do
        @id = "foobar"
        @instance.stubs(:get).returns({:id => @id})
      end

      should "populate properties with the data" do
        @instance.load!
        assert_equal @id, @instance.id
      end

      should "mark as loaded" do
        @instance.load!
        assert @instance.loaded?
      end

      should "return the instance" do
        assert_equal @instance, @instance.load!
      end
    end

    context "existence checking" do
      setup do
        @instance.stubs(:load!)
      end

      should "return true if the load succeeded" do
        assert @instance.exist?
      end

      should "return false if an exception is raised" do
        @instance.expects(:load!).raises(Fogli::Exception.new(:foo, :bar))
        assert !@instance.exist?
      end
    end

    context "reading properties" do
      setup do
        @instance.stubs(:get).returns({})
      end

      should "not load if accessing id" do
        assert !@instance.loaded?
        @instance.expects(:load!).never
        @instance.id
      end

      should "load on first property access" do
        @instance.expects(:load!).once
        @instance.updated_time
      end

      should "not load if loaded" do
        @instance.load!
        assert @instance.loaded?
        @instance.expects(:load!).never
        @instance.updated_time
      end
    end
  end
end
