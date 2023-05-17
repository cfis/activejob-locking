ActiveJob Locking
===================

[![Build Status](https://secure.travis-ci.org/lantins/activejob-locking.png?branch=master)](http://travis-ci.org/cfis/activejob-locking)
[![Gem Version](https://badge.fury.io/rb/activejob-locking.png)](http://badge.fury.io/rb/activejob-locking)

activejob-locking lets you control how ActiveJobs are enqueued and performed:

* Allow only one job to be enqueued at a time - thus a "unique" job
* Allow only one job to be performed at a time - thus a "serialized" job

There are many other similar gems including [resque-lock-timeout](https://github.com/lantins/resque-lock-timeout),
[activejob-traffic-control](https://github.com/nickelser/activejob-traffic_control), [activejob-lock](https://github.com/idolweb/activejob-lock),
[activejob-locks](https://github.com/erickrause/activejob-locks).  What is different about this gem is that it
is agnostic on the locking mechanism.  In the same way that ActiveJob works with many adapters, ActiveJob Locking 
works with a variety of locking gems.
 
Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'activejob-locking'
```

Unique Jobs
------------
Sometime you only want to enqueue one instance of a job.  No other similar job should be enqueued until the first one 
is completed. 

```ruby
class UniqueJob < ActiveJob::Base
  include ActiveJob::Locking::Unique

  # Make sure the lock_key is always the same
  def lock_key(object)
    self.class.name
  end
 
  def perform(object)
    # do some work
  end
end
```
Only one instance of this job will ever be enqueued.  If an additional job is enqueued, it will either be dropped and
never be enqueued or it will wait until the first job is performed.  That is controlled by the job
[options](##options) described below.


Serialized Jobs
------------
Sometimes you only want to perform one instance of a job at a time.  No other similar job should be performed until the first one 
is completed. 

```ruby
class SerializedJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  # Make sure the lock_key is always the same
  def lock_key(object)
    self.class.name
  end

  def perform
    # do some work
  end
end
```
Only one instance of this job will ever be performed.  If an additional job is enqueued, it will wait in its queue until
the first job is performed. 

Locking
------------
Locks are used to control how jobs are enqueued and performed. The idea is that locks are stored in a distributed
system such as [Redis](https://redis.io/) or [Memcached](https://memcached.org/) so they can be used by
multiple servers to coordinate the enqueueing and performing of jobs.

The ActiveJob Locking gem does not include a locking implementation. Instead it provides adapters for
distributed locking gems. 

Currently three gems are supported:

* [redis-semaphore](https://github.com/dv/redis-semaphore) 

* [suo](https://github.com/nickelser/suo)

* [redlock-rb](https://github.com/leandromoreira/redlock-rb)

If you would like to have an additional locking mechanism supported, please feel free to send in a pull request.

Please see the [options](##options) section below on how to specify a locking adapter.


Lock Key
---------

Notice that the code samples above include a `lock_key` method. The return value of this method is used by the
gem to create locks behind the scenes.  Thus it holds the key (pun intended) to controlling how jobs are enqueued
and performed.

By default the key is defined as:

```ruby
 def lock_key(*args)
   [self.class.name, serialize_arguments(self.arguments)].join('/')
 end 
```
Thus it has the format `<job class name>/<serialized_job_arguments>`

The args passed to the lock key method are the same that are passed to the job's perform method.

To use this gem, you will want to override this method per job.
  
### Examples

Allow only one job per queue to be enqueued or performed: 
  
```ruby
 def lock_key(*args)
   self.queue
 end 
```

Allow only one instance of a job class to be enqueued of performed:  
  
```ruby
 def lock_key(*args)
   self.class.name
 end 
```

Options
-------
The locking behavior can be dramatically changed by tweaking various options. There is a global set of options
available at:

```ruby
ActiveJob::Locking.options
```
This should be updated using a Rails initializer.  Each job class can override individual options as it sees fit.

### Adapter

Use the adapter option to specify which locking gem to use.  

Globally update:

```ruby
ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::SuoRedis
```
Locally update:

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  self.adapter = ActiveJob::Locking::Adapters::SuoRedis
end
```

### Hosts

An array of hosts for the distributed system. This format is dependent on the locking gem, but generally is a url or an existing Memcache or Redis
connection. Please refer to the appropriate locking gem's documentation.  

Globally update:

```ruby
ActiveJob::Locking.options.hosts = ['localhost']
```
Locally update:

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  self.hosts = ['localhost']
end
```

### lock_time

The is the time to live for any acquired locks.  For most locking gems this is mapped to their concept of "stale" locks.
That means that if an attempt is made to access the lock after it is expired, it will be considered unlocked.  That is in
contrast to aggressively removing locks for running jobs even if no other job has requested them.

The value is specified in seconds and defaults to 100.

Globally update:

```ruby
ActiveJob::Locking.options.lock_time = 100
```
Locally update:

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  self.lock_time = 100
end
```

You almost surely want the lock_time to be greater than the time it takes to execute the job.  Otherwise, the lock will expire
and extra jobs will start to run. When the job finishes, or fails, the lock will be released.  However, remember that the job 
could be terminated by the operating system or a monitoring system (such as monit). In that case, the lock won't be released
and will remain in force until its lock_time expires. 

### lock_acquire_time

The is the timeout for acquiring a lock.  The value is specified in seconds and defaults to 1. It must
be greater than zero and cannot be nil.

Globally update:

```ruby
ActiveJob::Locking.options.lock_acquire_time = 1
```
Locally update:

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Unique

  self.lock_acquire_time = 1
end
```

Remember that most locking gems block the current thread when trying to acquire a lock. Therefore you likely want
lock_acquire_time to be low.  However, the lower it is the more likely that unique jobs that are enqueued will 
expire and be dropped.

### enqueue_time

The is the time to re-enqueue a job if the lock_time has expired. Thus this value is only relevant for
serialized jobs since unique jobs will be dropped instead of enqueded.

The value is specified in seconds and defaults to 100.

Globally update:

```ruby
ActiveJob::Locking.options.enqueue_time = 100
```
Locally update:

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Serialized

  self.enqueue_time = 100
end
```

### AdapterOptions

This is a hash table of options that should be sent to the lock gem when it is instantiated. Read the lock 
gems documentation to find appropriate values.

Globally update:

```ruby
ActiveJob::Locking.options.adapter_options = {}
```
Locally update (notice the different method name to avoid potential conflicts):

```ruby
class ExampleJob < ActiveJob::Base
  include ActiveJob::Locking::Unique

  self.adapter_options = {}
end
```
