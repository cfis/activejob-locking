module ActiveJob
  module Locking
    module Serialized
      extend ::ActiveSupport::Concern

      included do
        include ::ActiveJob::Locking::Base

        around_perform do |job, block|
          if job.adapter.lock
            begin
              block.call
            ensure
              job.adapter.unlock
            end
          else
            job.class.set(wait: job.adapter.options.enqueue_time).perform_later(*job.arguments)
          end
        end
      end
    end
  end
end
