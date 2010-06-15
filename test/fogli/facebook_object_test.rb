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

      should "be able to limit by fields" do
        result = @klass.find(:foo, :fields => "name")
        assert_equal [:name], result.instance_variable_get(:@_fields)
      end

      should "return an array of objects if multiple IDs are given" do
        result = @klass.find(1,2,3)
        assert result.is_a?(Array)
        result.each do |item|
          assert_equal result, item._collection

          # Make sure they're not the same instance of the array, even
          # though they have the same contents
          assert !result.equal?(item._collection)
        end
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

      should "store the fields given to it as symbols" do
        fields = ["foo", :bar, :baz]
        instance = @klass.new(:_fields => fields)
        assert_equal [:foo, :bar, :baz], instance._fields
      end

      should "store the collection given" do
        collection = [:foo, :bar]
        instance = @klass.new(:_collection => collection)
        assert_equal collection, instance._collection
      end

      should "store the collection as self if not given" do
        instance = @klass.new
        assert_equal [instance], instance._collection
      end
    end
  end

  context "with an instance" do
    setup do
      @instance = @klass.new
    end

    [:get, :post].each do |method|
      should "prepend any #{method} requests with the ID" do
        id = "foo"
        RestClient.expects(method).with() do |url, other|
          assert url =~ /\/foo\/bar$/, "Invalid URL: #{url}"
          true
        end

        @instance.stubs(:id).returns(id)
        @instance.send(method, "/bar")
      end

      should "not preprend #{method} requests with ID if specified" do
        RestClient.expects(method).with() do |url, other|
          assert url =~ /\.com\/bar$/, "Invalid URL: #{url}"
          true
        end

        @instance.stubs(:id).returns("foo")
        @instance.send(method, "/bar", :_no_id => true)
      end
    end

    context "deleting" do
      should "post with the delete method" do
        @instance.expects(:post).with(:method => :delete).once
        @instance.delete
      end
    end

    context "loading" do
      setup do
        @id = "foobar"
        @data = { @instance.id => {:id => @id}}
        @instance.stubs(:get).returns(@data)
      end

      should "get only the fields specified, if specified" do
        instance = @klass.find(@id, :fields => [:a, :b, :c])
        instance.expects(:get).returns(@data).with() do |path, params|
          assert_equal "a,b,c", params[:fields]
          true
        end
        instance.load!
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

    context "resource URI" do
      should "return the proper URI" do
        uri = "http://#{Fogli::FacebookGraph::GRAPH_DOMAIN}/#{@instance.id}"
        assert_equal uri, @instance.resource_uri
      end
    end

    context "picture" do
      should "return the proper URI" do
        assert_equal "#{@instance.resource_uri}/picture", @instance.picture
      end
    end

    context "reading properties" do
      setup do
        @instance.stubs(:get).returns({})
        @instance.populate_properties(:id => :foo)
      end

      should "not load if accessing id" do
        assert !@instance.loaded?
        @instance.expects(:load!).never
        @instance.id
      end

      should "not load if its a new record" do
        @instance = @klass.new
        @instance.expects(:load!).never
        @instance.updated_time
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
