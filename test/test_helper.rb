require 'bundler'
Bundler.require(:default, :test)

require 'minitest/autorun'

# To make debugging easier, test within this source tree versus an installed gem
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'activejob-locking'

require 'activejob/locking/adapters/redis-semaphore'
require 'activejob/locking/adapters/redlock'
require 'activejob/locking/adapters/suo-redis'

require_relative './jobs/unique_job'
require_relative './jobs/fail_job'
require_relative './jobs/serial_job'

def redis_reset
  Kernel.system('redis-cli FLUSHALL')
end