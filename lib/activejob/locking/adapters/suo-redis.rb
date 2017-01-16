require 'suo'

module ActiveJob
  module Locking
    module Adapters
      class SuoRedis < Base
        def create_lock_manager
          mapped_options = {connection: {host: self.options.hosts},
                            stale_lock_expiration: self.options.time,
                            acquisition_timeout: self.options.timeout}

          Suo::Client::Redis.new(self.key, mapped_options)
        end

        def lock
          self.lock_token = self.lock_manager.lock
        end

        def unlock
          self.lock_manager.unlock(self.lock_token)
        end
      end
    end
  end
end
