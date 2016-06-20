require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require "test/unit"

class TestBuildCancel < Test::Unit::TestCase

  def test_build_cancel_basic
    xxx = Veyor.build_start(project: 'cowsay')
    res = Veyor.build_cancel(project: 'cowsay', version: xxx['version'])
    assert_equal(Fixnum, res.class)
    assert_equal(204, res)
  end

end
