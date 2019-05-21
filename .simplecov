SimpleCov.start do
  add_filter "lib/veyor/faraday.rb"

  if ENV['CI']=='true'
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end
