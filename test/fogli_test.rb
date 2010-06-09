require 'test_helper'

class FogliTest < Test::Unit::TestCase
  context "config accessors" do
    [:client_id, :client_secret, :access_token, :redirect_uri, :logger].each do |key|
      should "be able to access and read #{key}" do
        value = "foo#{key}"
        Fogli.send("#{key}=", value)
        assert_equal value, Fogli.send(key)

        # Reset the value
        Fogli.send("#{key}=", nil)
      end
    end
  end
end
