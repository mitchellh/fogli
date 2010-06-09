require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ScopeMethodsTest < Test::Unit::TestCase
  setup do
    @module = Fogli::FacebookObject::ScopeMethods
  end

  context "scope methods" do
    setup do
      @klass = Class.new
      @klass.send(:include, @module)
      @instance = @klass.new
    end

    [:limit, :offset, :until, :since].each do |scope|
      should "return a new connection scope for #{scope}" do
        value = "#{scope}_foo"
        result = @instance.send(scope, value)
        assert_equal value, result.options[scope]
        assert_equal @instance, result.proxy
      end
    end

    should "initialize a scope for fields" do
      tests = [
               ["name,birthday,location"],
               [:name, :birthday, :location],
               [["name", :birthday], :location],
               [["name"], [[[:birthday]], :location]]
              ]

      tests.each do |args|
        scope = @instance.fields(*args)
        assert_equal "name,birthday,location", scope.options[:fields]
      end
    end
  end


  context "scope initializer args" do
    context "not a connection scope" do
      setup do
        @klass = Class.new
        @klass.send(:include, @module)
        @instance = @klass.new
      end

      should "return the proxy if not a connection scope" do
        proxy, options = @instance._scope_initializer_args(:foo, :bar)
        assert_equal @instance, proxy
        assert_equal({:foo => :bar}, options)
      end
    end

    context "in a connection scope" do
      setup do
        @proxy = mock("proxy")
        @options = { :foo => :bar }
        @instance = Fogli::FacebookObject::ConnectionScope.new(@proxy, @options)
      end

      should "return the proxy and merged options" do
        proxy, options = @instance._scope_initializer_args(:bar, :baz)
        assert_equal @proxy, proxy
        assert_equal(@options.merge(:bar => :baz), options)
      end
    end
  end
end
