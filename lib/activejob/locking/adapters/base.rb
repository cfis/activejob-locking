module ActiveJob
  module Locking
    module Adapters
      class Base
        attr_reader :key, :options, :lock_manager
        attr_accessor :lock_token

        def initialize(key, options)
          @key = key
          @options = options
          @lock_manager = self.create_lock_manager
        end

        def create_lock_manager
          raise('Subclass must implement')
        end

        def lock
          raise('Subclass must implement')
        end

        def unlock
          raise('Subclass must implement')
        end

        def refresh_lock!(refresh)
          raise('Subclass must implement')
        end
      end
    end
  end
end