require "helper"

class TestGem < Minitest::Test
  context "init without yaml" do
    context "load sources" do
      setup do
        system("rm test/conf/test_load.yml")
        `gem sources --add https://rubygems.org/`
        @gem_load = Gsm::Gem.new("test/conf/test_load.yml")
      end

      should "load no use_name" do
        assert_equal("", @gem_load.use_name)
      end

      should "load sources from gem command" do
        assert_equal(1, @gem_load.name_pivot)
        assert_equal({"Amethyst" => "https://rubygems.org/"}, @gem_load.sources)
      end

      teardown do
        system("rm test/conf/test_load.yml")
      end
    end

    context "generate names" do
      setup do
        system("rm test/conf/test_name.yml")
        @gem_name = Gsm::Gem.new("test/conf/test_name.yml")
      end

      should "pass pivot when name exsits" do
        @gem_name.add("Emerald", "http://aaa")
        @gem_name.load("http://aaa\nhttps://aaa\nhttp://bbb")
        assert_equal(true, @gem_name.sources.has_key?("Chrysocolla"))
        assert_equal(true, @gem_name.sources.has_key?("Hematite"))
      end

      should "add postfix when list is long" do
        source_list = <<EOB
http://1
http://2
http://3
http://4
http://5
http://6
http://7
http://8
http://9
http://10
http://11
http://12
http://13
http://14
http://15
http://16
http://17
http://18
http://19
http://20
http://21
http://22
http://23
EOB
        assert_equal(false, @gem_name.load(source_list))
        assert_equal(11, @gem_name.sources.length)
      end

      teardown do
        system("rm test/conf/test_name.yml")
      end
    end

    context "use source" do
      setup do
        system("rm test/conf/test_use.yml")
        @gem_use = Gsm::Gem.new("test/conf/test_use.yml")
        `gem sources --add https://rubygems.org/`
      end

      should "succeed" do
        @gem_use.use("Amethyst")
        outputs = `gem sources -l`
        assert_equal("*** CURRENT SOURCES ***\n\nhttps://rubygems.org/\n", outputs)
      end

      should "fail to apply source" do
        @gem_use.add("FailSource", "https://ruby-gems.org/")
        assert_equal(false, @gem_use.use("FailSource"))
      end

      teardown do
        system("rm test/conf/test_use.yml")
      end
    end

    context "add source" do
      setup do
        system("rm test/conf/test_add.yml")
        @gem_add = Gsm::Gem.new("test/conf/test_add.yml")
      end

      should "return false when name is empty" do
        assert_equal(false, @gem_add.add("", ""))
      end

      should "return false when name is nil" do
        assert_equal(false, @gem_add.add(nil, ""))
      end

      should "return false when name's length is large than 32" do
        assert_equal(false, @gem_add.add("abcdefghijklmnopqrstuvwxyzqwertyu", ""))
      end

      should "return false when name exists" do
        assert_equal(false, @gem_add.add("Amethyst", ""))
      end

      should "return false when url is invalid" do
        assert_equal(false, @gem_add.add("Test", "http-://rubygems.org/"))
      end

      should "return name when succeed" do
        assert_equal("Test", @gem_add.add("Test", "https://rubygems.org/"))
        assert_equal(true, @gem_add.sources.has_key?("Test"))
        assert_equal("https://rubygems.org/", @gem_add.sources["Test"])
      end

      teardown do
        system("rm test/conf/test_add.yml")
      end
    end

    context "delete source" do
      setup do
        system("rm test/conf/test_del.yml")
        @gem_del = Gsm::Gem.new("test/conf/test_del.yml")
        @gem_del.add("Test", "https://rubygems.org/")
      end

      should "return false if source is in use" do
        @gem_del.add("Amethyst", "https://rubygems.org/")
        @gem_del.use("Amethyst")
        assert_equal(false, @gem_del.del("Amethyst"))
      end

      should "return nil if source inexists" do
        assert_nil(@gem_del.del("aaa"))
      end

      should "return name if succeed" do
        assert_equal("Test", @gem_del.del("Test"))
      end

      teardown do
        system("rm test/conf/test_del.yml")
      end
    end
  end

  context "init with good yaml" do
    setup do
      @gem = Gsm::Gem.new("test/conf/good.yml")
      system("cp test/conf/good.yml test/conf/good.yml.bak")
    end

    should "use_name be rubygems" do
      assert_equal("rubygems", @gem.use_name)
      assert_equal("rubygems", @gem.get)
    end
    
    should "list sources" do
      expect = {
        "rubygems" => "https://rubygems.org/",
        "rubychina" => "https://gems.ruby-china.org/",
        "rubytaobao" => "https://ruby.taobao.org/"
      }
      assert_equal(expect, @gem.sources)
    end

    should "return gem url in use when calling to_s" do
      assert_equal("https://rubygems.org/", @gem.to_s)
    end

    should "reset all data" do
      @gem.reset
      assert_empty(@gem.use_name)
      assert_empty(@gem.sources)
    end

    teardown do
      system("mv test/conf/good.yml.bak test/conf/good.yml")
    end
  end

  context "init with multiple local gem sources" do
  end
end