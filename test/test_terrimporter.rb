require 'test_helper'

class TestTerrimporter < Test::Unit::TestCase

  def setup

  end

  def teardown

  end

  should 'build options as a combination form argument options and environment options' do
    ENV['TERRIMPORTER_OPTS'] = {}

    TerrImporter::Application.build_options()
  end


end
