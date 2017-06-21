%w(
  test_serialized_memory
  test_serialized_redis_semaphore
  test_serialized_redlock
  test_serialized_suo_redis
  test_unique_memory
  test_unique_redis_semaphore
  test_unique_redlock
  test_unique_suo_redis
).each do |test|
  require File.expand_path("../#{test}", __FILE__)
end
