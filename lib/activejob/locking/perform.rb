module ActiveJob
  module Locking
    module Perform
      extend ::ActiveSupport::Concern

      included do
        include ::ActiveJob::Locking::Base

        around_perform do |job, block|
          if self.adapter.lock
            begin
              block.call
            ensure
              self.adapter.unlock
            end
          else
            self.class.set(wait: 5.seconds).perform_later(job)
          end
        end
      end
    end
  end
end
