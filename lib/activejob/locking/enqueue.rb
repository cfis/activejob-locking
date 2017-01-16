module ActiveJob
  module Locking
    module Enqueue
      extend ::ActiveSupport::Concern

      included do
        include ::ActiveJob::Locking::Base

        before_enqueue do |job|
          lock = self.adapter.lock
          throw :abort unless lock
        end

        after_perform do |job|
          self.adapter.unlock
        end
      end
    end
  end
end
