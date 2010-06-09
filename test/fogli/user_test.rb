require File.join(File.dirname(__FILE__), '..', 'test_helper')

class UserTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::User
  end

  context "checking authorization" do
    setup do
      # Don't want any HTTP calls going out
      @object = Fogli::FacebookObject.new
      @object.stubs(:load!)
      @klass.stubs(:find).returns(@object)
    end

    should "return true if nothing is raised" do
      assert @klass.authorized?
    end

    should "return false if an exception is raised" do
      @object.expects(:load!).raises(Fogli::Exception.new("foo", "bar"))
      assert !@klass.authorized?
    end
  end
end
