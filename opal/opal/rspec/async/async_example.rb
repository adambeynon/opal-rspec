class Opal::RSpec::AsyncExample < ::RSpec::Core::Example  
  def run(example_group_instance, reporter)
    promise = Promise.new
    @example_group_instance = example_group_instance
    ::RSpec.current_example = self

    start(reporter)
    ::RSpec::Core::Pending.mark_pending!(self, pending) if pending?
    
    if skipped?
      ::RSpec::Core::Pending.mark_pending! self, skip
    elsif !::RSpec.configuration.dry_run?
      # TODO: around example needs to be async
      with_around_example_hooks do          
        run_before_example
        # Our wrapped block will execute with self == the group, not as the example, so we need to hold onto this for our promise resolve
        example_scope = self        
        wrapped_block = lambda do |example|
          done = lambda do
            if @@async_exception
              # exception needs to be set before calling finish so results are correct
              example_scope.set_exception @@async_exception
            end
            example_scope.run_after_example
            # Using run method parameter here since self != the example (see above)
            example_group_instance.instance_variables.each do |ivar|
              example_group_instance.instance_variable_set(ivar, nil)
            end
            example_scope.instance_variable_set(:@example_group_instance, nil)
            example_scope.finish(reporter)              
            ::RSpec.current_example = nil
            promise.resolve @@async_exception == nil
          end
          @@async_exception = nil
          self.instance_exec(done, example, &example_scope.instance_variable_get(:@example_block))
        end
        
        @example_group_instance.instance_exec(self, &wrapped_block)

        if pending?
          ::RSpec::Core::Pending.mark_fixed! self

          raise ::RSpec::Core::Pending::PendingExampleFixedError,
                'Expected example to fail since it is pending, but it passed.',
                [location]
        end        
      end
    end
    promise
  end
end
