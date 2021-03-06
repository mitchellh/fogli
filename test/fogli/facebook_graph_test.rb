require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookGraphTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookGraph
  end

  context "requesting" do
    teardown do
      Fogli.access_token = nil
    end

    [:get, :post, :delete, :head].each do |method|
      should "properly request #{method} type" do
        @klass.expects(:request).with(method, "/foo", {}).once
        @klass.send(method, "/foo", {})
      end

      should "properly have a raw request for #{method} type" do
        RestClient.expects(method).with("/foo", {}).once
        @klass.send("raw_#{method}".to_sym, "/foo", {})
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

    should "convert params to strings for GET/DELETE" do
      params = { :limit => 1 }
      RestClient.expects(:get).with("http://#{@klass::GRAPH_DOMAIN}/foo?limit=1", {}).once
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
      response = mock("response")
      response.stubs(:headers).returns({:content_type => "text/plain"})
      response.stubs(:body).returns(data)
      response.stubs(:code).returns(200)
      response
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

    should "raise an exception for a 500 response code" do
      resp = response({})
      resp.stubs(:code).returns(500)
      assert_raises(Fogli::Exception) do
        @klass.error_check { resp }
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

  context "parsing response" do
    setup do
      @headers = {}
      @body = "[1]"

      @response = mock("response")
      @response.stubs(:headers).returns(@headers)
      @response.stubs(:body).returns(@body)
    end

    should "simply return if the content-type is text/plain" do
      @headers[:content_type] = "text/plain; foo=bar"
      assert_equal @body, @klass.parse_response(@response)
    end

    should "parse JSON otherwise" do
      @headers[:content_type] = "anything"
      result= @klass.parse_response(@response)
      assert result.is_a?(Array)
      assert_equal 1, result[0]
    end

    should "return the raw body if a JSON parse error occurs" do
      @headers[:content_type] = "whatever"
      @body = "true"
      @response.stubs(:body).returns(@body)
      assert_equal @body, @klass.parse_response(@response)
    end
  end
end
