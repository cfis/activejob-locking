module ActiveJob
  module Locking
    module Unique
      extend ::ActiveSupport::Concern

      included do
        include ::ActiveJob::Locking::Base

        before_enqueue do |job|
          lock = job.adapter.lock
          throw :abort unless lock
        end
        
        around_perform do |job, block|
          block.call
        ensure
          job.adapter.unlock
        end
      end
    end
  end
end
