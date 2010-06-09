require File.join(File.dirname(__FILE__), '..', 'test_helper')

class PostTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::Post
    @instance = @klass.new
  end

  should "be able to like a post" do
    @instance.expects(:post).with("/likes").once
    @instance.like!
  end

  should "be able to unlike a post" do
    @instance.expects(:post).with("/likes", :method => :delete).once
    @instance.unlike!
  end
end
