require File.join(File.dirname(__FILE__), '..', 'test_helper')

class OAuthObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::OAuth
  end

  context "authorization URL" do
    teardown do
      Fogli.client_id = nil
      Fogli.redirect_uri = nil
    end

    should "return the URL escape the URI" do
      options = { :client_id => "foo", :redirect_uri => "bar baz" }
      expected = @klass::AUTHORIZE_URI % ["foo", "bar+baz"]
      assert_equal expected, @klass.authorize(options)
    end

    should "by default use the global client id and redirect uri" do
      Fogli.client_id = "foo"
      Fogli.redirect_uri = "bar"
      expected = @klass::AUTHORIZE_URI % ["foo", "bar"]
      assert_equal expected, @klass.authorize
    end
  end

  context "access token" do
    teardown do
      Fogli.client_id = nil
      Fogli.client_secret = nil
    end

    should "by default use the global client ID and secret" do
      Fogli.client_id = "foo"
      Fogli.client_secret = "bar"
      options = { :redirect_uri => "bar", :code => "baz" }
      merged = options.merge({ :client_id => Fogli.client_id,
                               :client_secret => Fogli.client_secret })
      @klass.expects(:get).with("/oauth/access_token", :query => merged).returns("")
      @klass.access_token(options)
    end
  end
end
