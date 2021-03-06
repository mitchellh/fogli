require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class FacebookObjectConnectionScopeTest < Test::Unit::TestCase
  setup do
    @klass = Fogli::FacebookObject::ConnectionScope

    @proxy = Fogli::FacebookObject::ConnectionProxy.new(Fogli::FacebookObject.new,
                                                        :foo,
                                                        {:class => :Post})
    @options = {}
    @instance = @klass.new(@proxy, @options)
  end

  context "each" do
    setup do
      @instance.clear_cache
    end

    def stub_data(*values)
      { "data" => values }
    end

    should "load the initial data if its not yet loaded" do
      @instance.expects(:load!).once
      @instance.each {}
    end

    should "load as page end is reached" do
      @instance.expects(:load!).once.returns(false)

      data = [stub_data(1,2,3), stub_data(4,5,6)]
      @instance.instance_variable_set(:@_data, data)
      result = @instance.inject(0) do |acc, i|
        acc + i
      end

      assert_equal 21, result
    end

    should "limit the data to the specified amount" do
      data = [stub_data(1,2,3), stub_data(4,5,6), stub_data(7)]
      @instance.options[:limit] = 2
      @instance.instance_variable_set(:@_data, data)
      result = @instance.inject(0) { |a,i| a + 1 }
      assert_equal 2, result
    end
  end

  context "loading" do
    setup do
      @instance.clear_cache
    end

    should "default the fields to all of the parent's if not specified" do
      assert @instance.options[:fields].nil? # sanity check
      @proxy.expects(:load).with() do |scope|
        assert scope.options[:fields]
        assert_equal Fogli::Post.properties.keys.join(","), scope.options[:fields]
        true
      end

      @instance.load!
    end

    should "load the first page if data hasn't been loaded yet" do
      data = mock("data")
      @proxy.expects(:load).with(@instance).returns(data)
      assert @instance.load!
      assert_equal data, @instance._data.first
    end

    should "load the next page if the data has already been loaded and has next page" do
      data = { "paging" => { "next" => "foo" } }
      raw = { "data" => [] }
      @proxy.stubs(:load).returns(data)
      @instance.load!
      Fogli::FacebookGraph.expects(:raw_get).with(data["paging"]["next"]).once.returns(raw)
      @proxy.expects(:parse_data).with(raw).returns(raw)
      assert @instance.load!
      assert_equal raw, @instance._data.last
    end

    should "return false if no next page is available" do
      data = { "paging" => { } }
      @proxy.stubs(:load).returns(data)
      @instance.load!
      Fogli::FacebookGraph.expects(:raw_get).never
      assert !@instance.load!
    end
  end
end
