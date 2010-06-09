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
      @scope = Fogli::FacebookObject::ConnectionScope.new(@instance)
    end

    should "get the connection with the scope options and parse the data" do
      @parent.expects(:get).with("/#{@connection_name}", @scope.options).once.returns(nil)
      assert_equal({"data"=>[]}, @instance.load(@scope))
    end
  end

  context "parsing data" do
    should "instantiate for each data item" do
      data = {"data" => [{"id"=>"1"},{"id"=>"2"}]}
      @instance.stubs(:connection_class).returns(Fogli::FacebookObject)
      result = @instance.parse_data(data)
      assert_equal data["data"].length, result["data"].length
      assert_equal "1", result["data"][0].id
    end
  end

  context "connection class" do
    should "just return the class if specified" do
      @connection_options[:class] = :User
      assert_equal Fogli::User, @instance.connection_class
    end
  end
end
