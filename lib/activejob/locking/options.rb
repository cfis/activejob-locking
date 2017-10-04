require 'ostruct'

module ActiveJob
  module Locking
    class Options
      attr_accessor :adapter
      attr_accessor :hosts
      attr_accessor :lock_time
      attr_accessor :lock_acquire_time
      attr_accessor :enqueue_time
      attr_accessor :adapter_options

      def initialize(options = {})
        @adapter = options[:adapter]
        @hosts = options[:hosts]
        @enqueue_time = options[:enqueue_time]
        @lock_time = options[:lock_time]
        @lock_acquire_time = options[:lock_acquire_time]
        @adapter_options = options[:adapter_options]
      end

      def enqueue_time=(value)
        case value
          when NilClass
            raise(ArgumentError, 'Enqueue time must be set')
          when ActiveSupport::Duration
            @enqueue_time = value.value
          when 0
            raise(ArgumentError, 'Enqueue time must be greater than zero')
          else
            @enqueue_time = value
        end
      end

      def lock_time=(value)
        case value
          when NilClass
            raise(ArgumentError, 'Lock time must be set')
          when ActiveSupport::Duration
            @lock_time = value.value
          when 0
            raise(ArgumentError, 'Lock time must be greater than zero')
          else
            @lock_time = value
        end
      end

      def lock_acquire_time=(value)
        case value
          when NilClass
            raise(ArgumentError, 'Lock acquire time must be set')
          when ActiveSupport::Duration
            @lock_acquire_time = value.value
          when 0
            raise(ArgumentError, 'Lock acquire time must be greater than zero')
          else
            @lock_acquire_time = value
        end
      end

      def merge(other)
        result = self.dup
        result.adapter = other.adapter if other.adapter
        result.hosts = other.hosts if other.hosts
        result.enqueue_time = other.enqueue_time if other.enqueue_time
        result.lock_time = other.lock_time if other.lock_time
        result.lock_acquire_time = other.lock_acquire_time if other.lock_acquire_time
        result.adapter_options = other.adapter_options if other.adapter_options
        result
      end
    end
  end
end