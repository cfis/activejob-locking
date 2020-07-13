require 'redlock'

module ActiveJob
  module Locking
    module Adapters
      class Redlock < Base
        def create_lock_manager
          mapped_options = self.options.adapter_options
          mapped_options[:retry_count] = 2 # Try to get the lock and then try again when timeout is expiring--
          mapped_options[:retry_delay] = self.options.lock_acquire_time * 1000 # convert from seconds to milliseconds

          ::Redlock::Client.new(self.options.hosts, mapped_options)
        end

        def lock
          self.lock_token = self.lock_manager.lock(self.key, self.options.lock_time * 1000)
        end

        def unlock
          self.lock_manager.unlock(self.lock_token.symbolize_keys)
          self.lock_token = nil
        end
      end
    end
  end
end
