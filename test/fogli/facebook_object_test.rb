require File.join(File.dirname(__FILE__), '..', 'test_helper')

class FacebookObjectTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject
  end

  should "include the properties module" do
    assert @klass.included_modules.include?(Fogli::FacebookObject::Properties)
  end

  should "have an id property" do
    assert @klass.properties.keys.include?(:id)
  end

  should "have a updated_time property" do
    assert @klass.properties.keys.include?(:updated_time)
  end

  should "propagate properties to subclasses" do
    @subklass = Class.new(@klass)
    assert @subklass.properties.keys.include?(:id)
  end

  should "propagate connections to subclasses" do
    @klass.connection :foo
    @subklass = Class.new(@klass)
    assert @subklass.connections.keys.include?(:foo)
    @klass.connections.clear
  end
end
