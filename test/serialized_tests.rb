require File.expand_path('../test_helper', __FILE__)

module SerializedTests
  def test_one_completed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = SerialJob.lock_acquire_time / 0.9
    threads = 3.times.map do |i|
      Thread.new do
        SerialJob.perform_later(i, sleep_time)
      end
    end

    # All the threads will complete after the sleep time has expired - since two jobs get requeued
    threads.each {|thread| thread.join}
    assert_equal(2, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(3, ActiveJob::Base.queue_adapter.performed_jobs.count)

    assert(Time.now - start_time > (1 * sleep_time))
  end

  def test_some_completed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = SerialJob.lock_acquire_time / 1.9
    threads = 3.times.map do |i|
      Thread.new do
        SerialJob.perform_later(i, sleep_time)
      end
    end

    # All the threads will complete after the sleep time has expired - since two jobs get requeued
    threads.each {|thread| thread.join}
    assert_equal(1, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(3, ActiveJob::Base.queue_adapter.performed_jobs.count)

    assert(Time.now - start_time > (1 * sleep_time))
  end

  def test_all_completed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = SerialJob.lock_acquire_time / 4
    threads = 3.times.map do |i|
      Thread.new do
        SerialJob.perform_later(i, sleep_time)
      end
    end

    # All the threads will complete after the sleep time has expired - since two jobs get requeued
    threads.each {|thread| thread.join}
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(3, ActiveJob::Base.queue_adapter.performed_jobs.count)

    assert(Time.now - start_time > (1 * sleep_time))
  end
end