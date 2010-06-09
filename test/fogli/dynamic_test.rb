require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DynamicTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Dynamic
  end

  context "finding" do
    setup do
      @data = {
        "foo" => {
          "id" => "foo",
          "type" => "user"
        },
        "bar" => {
          "id" => "bar",
          "type" => "post"
        }
      }

      @klass.stubs(:get).returns(@data)
    end

    should "get and return the proper data" do
      @klass.expects(:get).with("/", :ids => "foo,bar", :metadata => 1).returns(@data)
      results = @klass.find(:foo, :bar)
      assert_equal 2, results.length
      assert_equal Fogli::User, results[0].class
      assert_equal Fogli::Post, results[1].class
    end
  end

  context "class for data" do
    should "return the proper class if given" do
      data = { "type" => "user" }
      assert_equal Fogli::User, @klass.class_for_data(data)
    end

    should "return a FacebookObject if nothing better can be found" do
      data = {}
      assert_equal Fogli::FacebookObject, @klass.class_for_data(data)
    end
  end
end
