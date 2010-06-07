require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookGraphTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookGraph
  end

  context "requesting" do
    teardown do
      Fogli.access_token = nil
    end

    [:get, :post, :delete].each do |method|
      should "properly request #{method} type" do
        @klass.expects(:request).with(method, "/foo", {}).once
        @klass.send(method, "/foo", {})
      end
    end

    should "use http by default" do
      RestClient.expects(:get).with("http://#{@klass::GRAPH_DOMAIN}/foo", {}).once
      @klass.request(:get, "/foo")
    end

    should "use https if an access token is set" do
      Fogli.access_token = "foo"
      RestClient.expects(:get).with("https://#{@klass::GRAPH_DOMAIN}/foo?access_token=foo", {}).once
      @klass.request(:get, "/foo")
    end

    should "append parameters for GET/DELETE" do
      params = { "foo" => "bar baz" }
      RestClient.expects(:get).with("http://#{@klass::GRAPH_DOMAIN}/foo?foo=bar+baz", {}).once
      @klass.request(:get, "/foo", params)
    end

    should "pass params into function for POST" do
      params = { :foo => :baz }
      RestClient.expects(:post).with("http://#{@klass::GRAPH_DOMAIN}/foo", params).once
      @klass.request(:post, "/foo", params)
    end
  end

  context "error checking" do
    def response(data)
      @klass.stubs(:parse_response).returns(data)
    end

    should "return the data if the data is fine" do
      data = { "foo" => "bar" }

      assert_equal data, @klass.error_check { response(data) }
    end

    should "raise an exception if the data represents an error" do
      data = { "error" => { "type" => "foo", "message" => "baz" }}
      assert_raises(Fogli::Exception) do
        @klass.error_check { response(data) }
      end
    end

    should "catch exceptions with responses" do
      data = { "foo" => "bar" }
      result = @klass.error_check do
        e = RestClient::Exception.new
        e.response = response(data)
        raise e
      end
    end
  end
end
