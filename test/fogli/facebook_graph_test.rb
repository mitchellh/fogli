require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookGraphTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookGraph
  end

  context "httparty" do
    should "include HTTParty" do
      assert @klass.included_modules.include?(HTTParty)
    end
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

    should "use proper original method" do
      @klass.expects(:post_original).once
      @klass.request(:post, "/foo")
    end

    should "use http by default" do
      @klass.expects(:get_original).with("http://#{@klass::GRAPH_DOMAIN}/foo", {}).once
      @klass.request(:get, "/foo")
    end

    should "use https if an access token is set" do
      options = {:query => {:access_token => "bar"}}
      @klass.expects(:get_original).with("https://#{@klass::GRAPH_DOMAIN}/foo", options).once
      @klass.request(:get, "/foo", options)
    end

    should "add access token if set statically" do
      Fogli.access_token = "foo"
      @klass.expects(:get_original).with(anything, {:query => {:access_token => "foo"}}).once
      @klass.request(:get, "/foo")
    end
  end

  context "error checking" do
    should "return the data if the data is fine" do
      data = { :foo => "bar" }
      assert_equal data, @klass.error_check(data)
    end

    should "raise an exception if the data represents an error" do
      data = { "error" => { "type" => "foo", "message" => "baz" }}
      assert_raises(Fogli::Exception) { @klass.error_check(data) }
    end
  end
end
