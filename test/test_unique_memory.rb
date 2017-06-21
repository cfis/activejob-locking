require_relative('./unique_tests')

class UniqueMemoryTest < MiniTest::Test
  include UniqueTests

  def setup
    ActiveJob::Locking::Adapters::Memory.reset
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::Memory
  end
end
