class FailJob < ActiveJob::Base
  include ActiveJob::Locking::Unique

  self.lock_acquire_time = 2

  # We want the job ids to be all the same for testing
  def lock_key(index, sleep_time)
    self.class.name
  end

  # Pass in index so we can distinguish different jobs
  def perform(index, sleep_time)
    raise(ArgumentError, 'Job failed')
  end
end