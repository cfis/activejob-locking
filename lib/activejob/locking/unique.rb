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

        rescue_from(Exception) do |exception|
          self.adapter.unlock
          raise
        end

        after_perform do |job|
          job.adapter.unlock
        end
      end
    end
  end
end
