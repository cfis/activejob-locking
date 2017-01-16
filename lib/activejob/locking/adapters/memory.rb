module ActiveJob
  module Locking
    module Adapters
      class Memory < Base
        attr_reader :timeout

        @hash = Hash.new
        @mutex = Mutex.new

        def self.lock(key)
          @mutex.synchronize do
            if @hash[key]
              false
            else
              @hash[key] = Time.now
            end
          end
        end

        def self.unlock(key)
          @mutex.synchronize do
            @hash.delete(key)
          end
        end

        def self.locked?(key)
          @mutex.synchronize do
            @hash.include?(key)
          end
        end

        def self.reset
          @mutex.synchronize do
            @hash = Hash.new
          end
        end

        def create_lock_manager
        end

        def lock
          finish = Time.now + self.options.timeout
          sleep_time = [5, self.options.timeout / 5].min

          begin
            lock = self.class.lock(key)
            return lock if lock
            sleep(sleep_time)
          end while Time.now < finish

          return false
        end

        def unlock
          self.class.unlock(self.key)
        end
      end
    end
  end
end