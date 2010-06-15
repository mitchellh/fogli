require File.join(File.dirname(__FILE__), '..', 'test_helper')

class AlbumTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Album
    @instance = @klass.new
  end

  should "be able to create an album" do
    @instance.name = :foo
    @instance.message = "hello"
    @instance.profile = 7
    result = ["id", 17171]

    @instance.expects(:post).returns(result).with() do |url, options|
      assert_equal "/#{@instance.profile}/albums", url
      assert_equal @instance.name, options[:name]
      assert_equal @instance.message, options[:message]
      true
    end

    assert_equal result[1], @instance.save
    assert_equal result[1], @instance.id
  end
end
