require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require "test/unit"

class TestProjectSettings < Test::Unit::TestCase

  def test_project_settings_basic
    res = Veyor.project_settings(project: 'cowsay')
    assert_equal(Hash, res.class)
    assert_equal(["project", "settings", "images", "buildClouds", "defaultImageName"], res.keys)
    assert_equal(Hash, res['settings']['configuration'].class)
  end

  def test_project_settings_yaml_back
    res = Veyor.project_settings(project: 'cowsay', yaml: true)
    assert_equal(String, res.class)
    assert_not_nil(res.match(/verbosity: minimal/))
  end

end
