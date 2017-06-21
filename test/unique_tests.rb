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
end