require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class ScopeMethodsTest < Test::Unit::TestCase
  setup do
    @module = Fogli::FacebookObject::ScopeMethods
  end

  context "not in a connection scope" do
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
  end

  context "in a connection scope" do
    setup do
      @proxy = mock("proxy")
      @options = { :foo => :bar }
      @instance = Fogli::FacebookObject::ConnectionScope.new(@proxy, @options)
    end

    [:limit, :offset, :until, :since].each do |scope|
      should "return a new connection scope for #{scope}, with options merged" do
        value = "#{scope}_foo"
        result = @instance.send(scope, value)
        assert_equal value, result.options[scope]
        assert_equal :bar, result.options[:foo]
        assert_equal @proxy, result.proxy
      end
    end
  end
end
