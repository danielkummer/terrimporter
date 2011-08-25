require "test_helper"

class TestOptions < Test::Unit::TestCase

  def setup_options(*arguments)
    @input_file = "testfile"
    @options = TerrImporter::Application::Options.new([@input_file] + arguments)
  end

  def self.for_options(*options)
    context options.join(' ') do
      setup do
        setup_options *options
      end
      yield
    end
  end

  context "default options" do
    setup { setup_options }

    should "be in verbose mode" do
      assert_equal true, @options[:verbose]
    end

    should "have no default import statement" do
      assert_nil @options[:import_css]
      assert_nil @options[:import_js]
      assert_nil @options[:import_images]
    end

    should 'show help if none of the required options are specified' do
      @options.show_help_on_no_options
      assert @options[:show_help]

       #self[:show_help] = true unless self[:import_css] or self[:import_js] or self[:import_images] or self[:init] or self[:version]
    end

    should 'not show help if one of the required options is specified' do
      @options[:import_css] = true
      @options.show_help_on_no_options
      assert_equal false, @options[:show_help]
       #self[:show_help] = true unless self[:import_css] or self[:import_js] or self[:import_images] or self[:init] or self[:version]
    end

  end

  for_options '--init' do
    should 'initialize configuration' do
      assert @options[:init]
    end
  end

  for_options '--init', 'replace' do
    should 'initialize configuration and replace existing' do
      assert_equal :replace, @options[:init]
    end
  end

    for_options '--init', 'backup' do
    should 'initialize configuration and backup existing' do
      assert_equal :backup, @options[:init]
    end
  end

  for_options '-c' do
    should 'import css files' do
      assert @options[:import_css]
    end
  end

  for_options '--css' do
    should 'import css files' do
      assert @options[:import_css]
    end
  end

  for_options '-j' do
    should 'import js files' do
      assert @options[:import_js]
    end
  end

  for_options '--js' do
    should 'import js files' do
      assert @options[:import_js]
    end
  end

  for_options '-i' do
    should 'import image files' do
      assert @options[:import_images]
    end
  end

  for_options '--img' do
    should 'import image files' do
      assert @options[:import_images]
    end
  end

  for_options '-a' do
    should 'import all files' do
      assert @options[:import_css]
      assert @options[:import_js]
      assert @options[:import_images]
    end
  end

  for_options '--all' do
    should 'import all files' do
      assert @options[:import_css]
      assert @options[:import_js]
      assert @options[:import_images]
    end
  end

  for_options '--help' do
    should 'show help' do
      assert @options[:show_help]
    end
  end

  for_options '-h' do
    should 'show help' do
      assert @options[:show_help]
    end
  end


  for_options '--version' do
    should 'show version' do
      assert @options[:show_version]
    end
  end


  for_options '' do
    should 'show help if no options supplied' do
      assert @options[:show_help]
    end
  end

  for_options '--config','param_config_file.yml', ' -a' do
    should 'use supplied yml file for configuration' do
      assert @options[:config_file].include?("param_config_file.yml")
    end
  end

  for_options '--no-verbose', '-a' do
    should 'use none verbose output' do
      assert_equal false, @options[:verbose]
    end
  end


end
