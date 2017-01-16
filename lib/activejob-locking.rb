require 'activejob/locking/adapters/base'
require 'activejob/locking/adapters/memory'

require 'activejob/locking/base'
require 'activejob/locking/enqueue'
require 'activejob/locking/perform'

require 'activejob/locking/options'

module ActiveJob
  module Locking
    @options = ActiveJob::Locking::Options.new(adapter: ActiveJob::Locking::Adapters::Memory,
                                               hosts: 'localhost',
                                               time: 100,
                                               timeout: 1,
                                               adapter_options: {})

    def self.options
      @options
    end
  end
end

