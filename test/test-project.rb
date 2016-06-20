require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require "test/unit"

class TestProject < Test::Unit::TestCase

  def test_project_basic
    res = Veyor.project(account: 'sckott', project: 'cowsay')
    assert_equal(Hash, res.class)
    assert_equal(['project', 'build'], res.keys)
    assert_equal('sckott', res['project']['accountName'])
    assert_equal('cowsay', res['project']['name'])
  end

  def test_project_account_name_from_config
    res = Veyor.project(project: 'cowsay')
    assert_equal(Hash, res.class)
    assert_equal(['project', 'build'], res.keys)
    assert_equal('sckott', res['project']['accountName'])
    assert_equal('cowsay', res['project']['name'])
  end

  def test_project_branch_param
    res = Veyor.project(project: 'cowsay', branch: 'changeback')
    assert_equal(Hash, res.class)
    assert_equal('changeback', res['build']['branch'])
  end

  def test_project_version_param
    res = Veyor.project(project: 'cowsay', version: '1.0.692')
    assert_equal(Hash, res.class)
    assert_equal('1.0.692', res['build']['version'])
  end

end
