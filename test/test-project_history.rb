require 'simplecov'
require "veyor"
require "test/unit"

class TestProjectHistory < Test::Unit::TestCase

  def test_project_history_basic
    res = Veyor.project_history(project: 'cowsay')
    assert_equal(Hash, res.class)
    assert_equal(Array, res['builds'].collect { |x| x['status'] }.class)
    assert_equal('sckott', res['project']['accountName'])
  end

  def test_project_history_limit_results
    res = Veyor.project_history(project: 'cowsay', limit: 3)
    assert_equal(Hash, res.class)
    assert_equal(['project', 'builds'], res.keys)
    assert_equal(3, res['builds'].length)
  end

  def test_project_history_branch_param
    res = Veyor.project_history(project: 'cowsay', branch: 'changeback')
    assert_equal(Hash, res.class)
    assert_equal('changeback', res['builds'][0]['branch'])
  end

end
