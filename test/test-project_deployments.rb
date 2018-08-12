require 'simplecov'
SimpleCov.start
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "veyor"
require "test/unit"

# class TestProjectDeployments < Test::Unit::TestCase

#   def test_project_deployments_none
#     res = Veyor.project_deployments(project: 'cowsay')
#     assert_equal(Hash, res.class)
#     assert_equal([], res['deployments'])
#   end

# end
