require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require "test/unit"

class TestBuildStart < Test::Unit::TestCase

  def test_build_start_basic
    res = Veyor.build_start(project: 'cowsay')
    assert_equal(Hash, res.class)
    assert_equal('queued', res['status'])

    # teardown
    Veyor.build_cancel(project: 'cowsay', version: res['version'])
  end

end
