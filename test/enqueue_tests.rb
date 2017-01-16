require File.expand_path('../test_helper', __FILE__)

module EnqueueTests
  def test_drop
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)

    start_time = Time.now
    sleep_time = 2
    threads = 2.times.map do |i|
      Thread.new do
        EnqueueDropJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(1, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > (1 * sleep_time))
  end

  def test_wait
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)

    start_time = Time.now
    sleep_time = 2
    threads = 3.times.map do |i|
      Thread.new do
        EnqueueWaitJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(threads.count, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > (threads.count * sleep_time))
  end

  def test_wait_large_timeout
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)

    start_time = Time.now
    sleep_time = 2 * EnqueueWaitTimeoutJob.lock_acquire_timeout
    threads = 3.times.map do |i|
      Thread.new do
        EnqueueWaitTimeoutJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(1, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > (1 * sleep_time))
  end

  def test_wait_timeout
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)

    start_time = Time.now
    sleep_time = 0.2 * EnqueueWaitLargeTimeoutJob.lock_acquire_timeout
    threads = 3.times.map do |i|
      Thread.new do
        EnqueueWaitLargeTimeoutJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(threads.count, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > (threads.count * sleep_time))
  end
end