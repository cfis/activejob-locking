require 'bundler'
Bundler.require(:default, :test)

require 'minitest/autorun'

# To make debugging easier, test within this source tree versus an installed gem
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'activejob-locking'

require 'activejob/locking/adapters/redis-semaphore'
require 'activejob/locking/adapters/redlock'
require 'activejob/locking/adapters/suo-redis'

require_relative './jobs/enqueue_drop_job'
require_relative './jobs/enqueue_wait_job'
require_relative './jobs/enqueue_wait_timeout_job'
require_relative './jobs/enqueue_wait_large_timeout_job'
require_relative './jobs/perform_serially_job'

def redis_reset
  Kernel.system('redis-cli FLUSHALL')
end