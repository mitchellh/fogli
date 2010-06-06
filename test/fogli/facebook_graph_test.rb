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

  context "getting" do
    teardown do
      Fogli.access_token = nil
    end

    should "use http by default" do
      @klass.expects(:get_original).with("http://#{@klass::GRAPH_DOMAIN}/foo", nil).once
      @klass.get("/foo")
    end

    should "use https if an access token is set" do
      options = {:query => {:access_token => "bar"}}
      @klass.expects(:get_original).with("https://#{@klass::GRAPH_DOMAIN}/foo", options).once
      @klass.get("/foo", options)
    end

    should "add access token if set statically" do
      Fogli.access_token = "foo"
      @klass.expects(:get_original).with(anything, {:query => {:access_token => "foo"}}).once
      @klass.get("/foo")
    end
  end
end
