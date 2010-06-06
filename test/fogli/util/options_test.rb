require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class OptionsUtilTest < Test::Unit::TestCase
  class OptionsUtilTestClass
    include Fogli::Util::Options
  end

  setup do
    @klass = OptionsUtilTestClass
    @instance = @klass.new
  end

  should "merge in the defaults" do
    defaults = { :foo => :bar }
    options = { :bar => :baz }
    assert_equal defaults.merge(options), @instance.verify_options(options, nil, defaults)
  end

  should "error if required keys are missing" do
    options = { :foo => :bar }
    assert_raises(ArgumentError) {
      @instance.verify_options(options, [:foo, :bar])
    }
  end

  should "not error if the required keys aren't missing" do
    options = { :foo => :bar }
    assert_nothing_raised {
      @instance.verify_options(options, [:foo])
    }
  end
end
