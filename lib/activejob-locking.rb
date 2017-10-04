require 'activejob/locking/adapters/base'
require 'activejob/locking/adapters/memory'

require 'activejob/locking/base'
require 'activejob/locking/unique'
require 'activejob/locking/serialized'

require 'activejob/locking/options'

module ActiveJob
  module Locking
    @options = ActiveJob::Locking::Options.new(adapter: ActiveJob::Locking::Adapters::Memory,
                                               hosts: ['localhost'],
                                               enqueue_time: 100, # seconds
                                               lock_time: 100, # seconds
                                               lock_acquire_time: 1, # seconds
                                               adapter_options: {})

    def self.options
      @options
    end
  end
end

