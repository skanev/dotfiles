$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rspec'
require 'mire'
#require 'super_diff/rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = %i(should expect)
  end

  config.mock_with :rspec do |c|
    c.syntax = %i(should expect)
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.define_derived_metadata(file_path: %r{/spec/mire/beholders/}) do |metadata|
    metadata[:type] = :beholder
  end

  config.include SpecHelpers::BeholderHelpers, type: :beholder
end
