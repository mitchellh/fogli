require File.join(File.dirname(__FILE__), '..', 'test_helper')

class OAuthObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::OAuth
  end

  context "authorization URL" do
    should "return the URL escape the URI" do
      options = { :client_id => "foo", :redirect_uri => "bar baz" }
      expected = @klass::AUTHORIZE_URI % ["foo", "bar+baz"]
      assert_equal expected, @klass.authorize(options)
    end

    should "by default use the global client id" do
      Fogli.client_id = "foo"
      options = { :redirect_uri => "bar" }
      expected = @klass::AUTHORIZE_URI % ["foo", "bar"]
      assert_equal expected, @klass.authorize(options)
    end
  end

  context "access token" do
    should "by default use the global client ID and secret" do
      Fogli.client_id = "foo"
      Fogli.client_secret = "bar"
      options = { :redirect_uri => "bar", :code => "baz" }
      merged = options.merge({ :client_id => Fogli.client_id,
                               :client_secret => Fogli.client_secret })
      @klass.expects(:get).with("/oauth/access_token", :query => merged)
      @klass.access_token(options)
    end
  end
end
