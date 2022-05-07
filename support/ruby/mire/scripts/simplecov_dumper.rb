# Reports coverage data to mire
#
# This is a weird little file intended to hijack the rspec runner. It will
# enable simplecov and then do what is necessary for Mire to get the coverage
# data. It is intended to be used with -r as an extra argument when running
# RSpec, like so:
#
#   rspec -r simplecov_dumper.rb some_spec.rb
#
# It's quite hacky, therefore it tries to be compatible with older Rubies.
require 'simplecov'

class MireSimplecovFormatter
  def format(result)
    if (key = ENV['MIRE_FIRE_REDIS_KEY'])
      require 'redis'
      redis = Redis.new
      redis.select(ENV['MIRE_FIRE_REDIS_CHANNEL'].to_i) if ENV['MIRE_FIRE_REDIS_CHANNEL']
      redis.set key, Marshal.dump(result), ex: 5
    end
  end
end

SimpleCov.start do
  self.formatter = MireSimplecovFormatter
  coverage_dir '/tmp/mire-coverage-dir'
end
