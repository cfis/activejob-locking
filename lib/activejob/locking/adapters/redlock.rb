require 'redlock'

module ActiveJob
  module Locking
    module Adapters
      class Redlock < Base
        def create_lock_manager
          mapped_options = self.options.adapter_options
          mapped_options[:retry_count] = ::Redlock::Client::DEFAULT_RETRY_COUNT
          mapped_options[:retry_delay] = 2000 * ((self.options.timeout || 2**32) / (::Redlock::Client::DEFAULT_RETRY_COUNT * 1.0))

          ::Redlock::Client.new(Array(self.options.hosts), mapped_options)
        end

        def lock
          self.lock_token = self.lock_manager.lock(self.key, self.options.time * 1000)
        end

        def unlock
          self.lock_manager.unlock(self.lock_token)
          self.lock_token = nil
        end
      end
    end
  end
end
