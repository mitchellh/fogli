require File.join(File.dirname(__FILE__), '..', 'test_helper')

class CommentTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Comment
    @instance = @klass.new
  end

  should "be able to create a comment" do
    @instance.message = "hello"
    @instance.parent_post = 7
    result = ["id", 17171]

    @instance.expects(:post).returns(result).with() do |url, options|
      assert_equal "/#{@instance.parent_post}/comments", url
      assert_equal @instance.message, options[:message]
      true
    end

    assert_equal result[1], @instance.save
    assert_equal result[1], @instance.id
  end
end
