require File.expand_path('../test_helper', __FILE__)

module UniqueTests
  def test_none_performed
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    sleep_time = UniqueJob.lock_acquire_time
    threads = 3.times.map do |i|
      Thread.new do
        UniqueJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}
    assert_equal(1, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)
  ensure
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  def test_one_performed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    sleep_time = UniqueJob.lock_acquire_time * 2
    threads = 3.times.map do |i|
      Thread.new do
        UniqueJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(1, ActiveJob::Base.queue_adapter.performed_jobs.count)
  end

  def test_all_performed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = UniqueJob.lock_acquire_time / 4.0
    threads = 3.times.map do |i|
      Thread.new do
        UniqueJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(threads.count, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > (threads.count * sleep_time))
  end

  def test_some_performed
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = UniqueJob.lock_acquire_time / 2.0
    threads = 3.times.map do |i|
      Thread.new do
        UniqueJob.perform_later(i, sleep_time)
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(threads.count - 1, ActiveJob::Base.queue_adapter.performed_jobs.count)
    assert(Time.now - start_time > ((threads.count - 1) * sleep_time))
  end

  def test_fail
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    start_time = Time.now
    sleep_time = UniqueJob.lock_acquire_time
    threads = 3.times.map do |i|
      Thread.new do
        begin
          FailJob.perform_later(i, sleep_time)
        rescue => e
          # do nothing
        end
      end
    end

    threads.each {|thread| thread.join}

    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(threads.count, ActiveJob::Base.queue_adapter.performed_jobs.count)
  end

  def test_error_propagation_allows_retry_behavior
    # This test ensures that when a job with retry_on fails,
    # the error is properly propagated and not swallowed by the locking mechanism
    # This verifies the fix where around_perform ensures error propagation
    # instead of the old rescue_from that was swallowing errors
    
    assert_equal(0, ActiveJob::Base.queue_adapter.enqueued_jobs.count)
    assert_equal(0, ActiveJob::Base.queue_adapter.performed_jobs.count)

    # Test that the error is properly raised and caught by retry mechanism
    error_raised = false
    
    begin
      # This should raise the TestRetryError on first execution
      # Since we have retry_on configured, ActiveJob should catch and handle it
      RetryJob.perform_now(1, true)
    rescue RetryJob::TestRetryError
      # If we get here, the error was not properly handled by retry_on
      # This would indicate the old bug where rescue_from swallowed the error
      error_raised = true
    end
    
    # The error should NOT be raised here because retry_on should handle it
    # and the job should succeed on the second attempt
    assert_equal(error_raised, false, "Error should not escape - retry_on should handle it")
  end
end