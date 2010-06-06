require File.join(File.dirname(__FILE__), '..', 'test_helper')

class RootFacebookObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::RootFacebookObject
  end

  context "finding" do
    setup do
      @klass.stubs(:get)
    end

    should "get the resource and populate the instance" do
      id = :foo
      data = { "id" => "22" }
      @klass.expects(:get).with("/#{id}").returns(data)
      result = @klass.find(id)
      assert_equal data["id"], result.id
    end
  end
end
