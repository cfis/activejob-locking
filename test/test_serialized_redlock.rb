require_relative('./serialized_tests')

class SerializedRedlockTest < MiniTest::Test
  include SerializedTests

  def setup
    redis_reset

    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::Redlock
    ActiveJob::Locking.options.hosts = Redlock::Client::DEFAULT_REDIS_URLS
  end
end