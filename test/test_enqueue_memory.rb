require_relative('./enqueue_tests')

class EnqueueMemoryTest < MiniTest::Test
  include EnqueueTests

  def setup
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::Memory
  end

  def test_enqueue_one
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::Memory

    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)

    sleep_time = 2
    threads = 3.times.map do |i|
      Thread.new do
        EnqueueDropJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}
    assert_equal(1, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
  end

  def test_perform_one
    ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::Memory

    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    sleep_time = 1
    threads = 3.times.map do |i|
      Thread.new do
        EnqueueDropJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}
    assert_equal(1, ActiveJob::Base.queue_adapter.performed_jobs.count)
  end
end
