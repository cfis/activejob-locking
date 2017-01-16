require 'ostruct'

module ActiveJob
  module Locking
    class Options
      attr_accessor :adapter
      attr_accessor :hosts
      attr_accessor :time
      attr_accessor :timeout
      attr_accessor :adapter_options

      alias :lock_time :time
      alias :lock_time= :time=
      alias :lock_acquire_timeout :timeout
      alias :lock_acquire_timeout= :timeout=

      def initialize(options = {})
        @adapter = options[:adapter]
        @hosts = options[:hosts]
        @time = options[:time]
        @timeout = options[:timeout]
        @adapter_options = options[:adapter_options]
      end

      def timeout=(value)
        if value.nil?
          raise(ArgumentError, 'Lock timeout must be set')
        elsif value == 0
          raise(ArgumentError, 'Lock timeout must be greater than zero')
        else
          @timeout = value
        end
      end

      def merge(other)
        result = self.dup
        result.adapter = other.adapter if other.adapter
        result.hosts = other.hosts if other.hosts
        result.time = other.time if other.time
        result.timeout = other.timeout if other.timeout
        result.adapter_options = other.adapter_options if other.adapter_options
        result
      end
    end
  end
end