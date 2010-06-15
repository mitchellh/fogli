require File.join(File.dirname(__FILE__), '..', 'test_helper')

class NoteTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Note
    @instance = @klass.new
  end

  should "be able to create a note" do
    @instance.message = "hello"
    @instance.subject = "hi"
    @instance.profile = 7
    result = ["id", 17171]

    @instance.expects(:post).returns(result).with() do |url, options|
      assert_equal "/#{@instance.profile}/notes", url
      assert_equal @instance.message, options[:message]
      assert_equal @instance.subject, options[:subject]
      true
    end

    assert_equal result[1], @instance.save
    assert_equal result[1], @instance.id
  end
end
