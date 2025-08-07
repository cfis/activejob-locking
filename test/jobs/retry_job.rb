class RetryJob < ActiveJob::Base
  include ActiveJob::Locking::Unique

  self.lock_acquire_time = 2

  # Custom error for testing retry behavior
  class TestRetryError < StandardError; end

  # Configure retry behavior (no wait time for test adapter)
  retry_on TestRetryError, attempts: 3

  # We want the job ids to be all the same for testing
  def lock_key(index, should_fail)
    self.class.name
  end

  # Pass in index and should_fail flag to control job behavior
  def perform(index, should_fail = true)
    if should_fail && executions == 1
      # Only fail on the first execution, succeed on retry
      raise TestRetryError, 'Job failed on first attempt'
    end
    # Job succeeds
  end
end