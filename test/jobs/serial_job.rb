class SerialJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  self.lock_acquire_time = 2

  # We want the job ids to be all the same for testing
  def lock_key
    self.class.name
  end

  # Pass in index so we can distinguish different jobs
  def perform(index, sleep_time)
    sleep(sleep_time)
  end
end