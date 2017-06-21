module ActiveJob
  module Locking
    module Base
      extend ::ActiveSupport::Concern

      module ClassMethods
        def lock_options
          @lock_options ||= ActiveJob::Locking::Options.new
        end
        delegate :adapter, :hosts, :lock_time, :lock_acquire_time, :adapter_options, to: :lock_options
        delegate :adapter=, :hosts=, :lock_time=, :lock_acquire_time=, :adapter_options=, to: :lock_options
      end

      included do
        # We need to serialize the lock token that some gems create because it could be released in a different process
        def serialize
          result = super
          result['lock_token'] = self.adapter.lock_token
          result
        end

        def deserialize(job_data)
          super
          self.adapter.lock_token = job_data['lock_token']
        end

        def lock_key
          [self.class.name, serialize_arguments(self.arguments)].join('/')
        end

        def adapter
          @adapter ||= begin
            # Make sure arguments are deserialized so calling lock key is safe
            deserialize_arguments_if_needed

            # Merge local and global options
            merged_options = ActiveJob::Locking.options.dup.merge(self.class.lock_options)

            # Remember the lock might be acquired in one process and released in another
            merged_options.adapter.new(self.lock_key, merged_options)
          end
          @adapter
        end
      end
    end
  end
end