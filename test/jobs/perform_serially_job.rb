class PerformSeriallyJob < ActiveJob::Base
  include ActiveJob::Locking::Perform

  self.lock_acquire_timeout = 1.hour

  # We want the job ids to be all the same for testing
  def lock_key
    self.class.name
  end

  # Pass in index so we can distinguish different jobs
  def perform(index, sleep_time)
    sleep(sleep_time)
  end
end