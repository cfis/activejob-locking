require 'redis-semaphore'

module ActiveJob
  module Locking
    module Adapters
      class RedisSemaphore < Base
        def create_lock_manager
          mapped_options = {host: self.options.hosts,
                            resources: 1,
                            stale_client_timeout: self.options.lock_time}.merge(self.options.adapter_options)

          Redis::Semaphore.new(self.key, mapped_options)
        end

        def lock
          self.lock_token = self.lock_manager.lock(self.options.lock_acquire_time)
        end

        def unlock
          self.lock_manager.signal(self.lock_token)
          self.lock_token = nil
        end
      end
    end
  end
end
