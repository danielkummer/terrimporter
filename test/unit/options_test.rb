require "helper"

class OptionsTest < Test::Unit::TestCase

  def setup_options(*arguments)
    #@input_file = "dummy.yml"
    @input_file = "testfile"
    @options = TerrImporter::Application::Options.new([@input_file] + arguments)
  end

  def self.for_options(*options)
    context options.join(' ') do
      setup do
        wrap_out { setup_options *options }
      end
      yield
    end
  end

  #todo not working
  def wrap_out
    original_stdout = $stdout
    original_stderr = $stderr

    fake_stdout = StringIO.new
    fake_stderr = StringIO.new

    $stdout = fake_stdout
    $stderr = fake_stderr

    begin
      yield if block_given?
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end
    @stdout = fake_stdout.string
    @stderr = fake_stderr.string
  end

  context "default options" do
    setup { setup_options }

    should "be in verbose mode" do
      assert_equal true, @options[:verbose]
    end

    should "have no default import statement" do
      assert_nil @options[:import_css]
      assert_nil @options[:import_js]
      assert_nil @options[:import_image]
    end

  end

  for_options '--init' do
    should 'initialize project' do
      assert @options[:init]
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
      assert @options[:import_image]
    end
  end

  for_options '--img' do
    should 'import image files' do
      assert @options[:import_image]
    end
  end

  for_options '-a' do
    should 'import all files' do
      assert @options[:import_css]
      assert @options[:import_js]
      assert @options[:import_image]
    end
  end

  for_options '--all' do
    should 'import all files' do
      assert @options[:import_css]
      assert @options[:import_js]
      assert @options[:import_image]
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
  for_options '-v' do
    should 'show version' do
      assert @stdout.include? "0.1.0"
    end
  end

end
