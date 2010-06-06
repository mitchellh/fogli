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

  context "with an instance" do
    setup do
      @instance = @klass.new
    end

    should "prepend any get requests with the ID" do
      id = "foo"
      @klass.expects(:get_original).with() do |url, options|
        assert url =~ /\/foo\/bar$/, "Invalid URL: #{url}"
        true
      end

      @instance.stubs(:id).returns(id)
      @instance.get("/bar")
    end
  end
end
