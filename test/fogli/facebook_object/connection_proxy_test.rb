require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class FacebookObjectConnectionProxyTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject::ConnectionProxy

    @parent = Fogli::FacebookObject.new
    @connection_name = "friends"
    @connection_options = { :class => :FacebookObject }
    @instance = @klass.new(@parent, @connection_name, @connection_options)
  end

  context "loading" do
    setup do
      # Make sure no actual HTTP requests go through
      @parent.stubs(:get)
    end

    should "just make empty if invalid data is found" do
      @parent.expects(:get).returns(nil)
      @instance.load!
      assert @instance.data.empty?
    end

    should "instantiate for each data" do
      data = {"data" => [{"id"=>"1"},{"id"=>"2"}]}
      @parent.expects(:get).returns(data)
      @instance.stubs(:connection_class).returns(Fogli::FacebookObject)
      @instance.load!
      assert_equal data["data"].length, @instance.data.length
      assert_equal data["data"][0]["id"], @instance.data[0].id
    end

    context "eager loading from parent" do
      setup do
        @parent._fields << @connection_name.to_sym
        @parent.stubs(:_raw).returns({ @connection_name.to_s => { "data" => [{"id"=>"1"}] }})
      end

      should "force load on parent then use cached data" do
        @parent.stubs(:loaded?).returns(false)
        @parent.expects(:load!).once
        @parent.expects(:get).never
        @instance.load!
        assert_equal "1", @instance.data[0].id
      end

      should "use cached data from parent if available" do
        @parent.stubs(:loaded?).returns(true)
        @parent.expects(:load!).never
        @parent.expects(:get).never
        @instance.load!
        assert_equal "1", @instance.data[0].id
      end
    end
  end

  context "enumerable" do
    setup do
      @instance.stubs(:data).returns([1,2,3])
      @instance.stubs(:loaded?).returns(true)
    end

    should "be enumerable" do
      assert @klass.included_modules.include?(Enumerable)
    end

    should "be able to access data via []" do
      assert_equal 2, @instance[1]
    end

    should "define each to iterate over the data" do
      sum = 0
      @instance.each { |i| sum += i }
      assert_equal 6, sum
    end

    should "load the data on `[]` if its not loaded" do
      @instance.stubs(:loaded?).returns(false)
      @instance.expects(:load!).once
      @instance[1]
    end

    should "load the data on `each` if its not loaded" do
      @instance.stubs(:loaded?).returns(false)
      @instance.expects(:load!).once
      @instance.each {}
    end
  end

  context "connection class" do
    should "just return the class if specified" do
      @connection_options[:class] = :User
      assert_equal Fogli::User, @instance.connection_class({})
    end
  end
end
