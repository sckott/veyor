require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require 'fileutils'
require "test/unit"
require "json"

class TestProjects < Test::Unit::TestCase

  def setup
    @res = Veyor.projects()
  end

  def test_projects
    assert_equal(Array, @res.class)
    assert_equal(Hash, @res[0].class)
    assert_equal('sckott', @res[0]['accountName'])
  end
end
