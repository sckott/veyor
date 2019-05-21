require 'simplecov'
require "veyor"
require "test/unit"

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
