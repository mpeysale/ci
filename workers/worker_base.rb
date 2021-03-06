require_relative "../shared/logging_module"

module FastlaneCI
  # super class for all fastlane.ci workers
  # Subclass this class, and implement `work` and `sleep_interval`
  class WorkerBase
    include FastlaneCI::Logging

    attr_accessor :should_stop
    attr_accessor :worker_id

    def thread_id=(new_value)
      @thread[:thread_id] = new_value
    end

    def thread_id
      return @thread[:thread_id]
    end

    def initialize
      self.should_stop = false

      @thread = Thread.new do
        until self.should_stop
          Kernel.sleep(self.sleep_interval)

          # We have the `work` inside a `begin rescue`
          # so that if something fails, the thread still is alive
          begin
            self.work unless self.should_stop
          rescue StandardError => ex
            puts("[#{self.class} Exception]: #{ex}: ")
            puts(ex.backtrace.join("\n"))
            puts("[#{self.class}] Killing thread #{self.thread_id} due to exception\n")
            self.should_stop = true
          end
        end
      end
    end

    def work
      not_implemented(__method__)
    end

    def provider_type
      not_implemented(__method__)
    end

    def die!
      logger.debug("Stopping worker")
      @should_stop = true
    end

    # Sleep in seconds
    def sleep_interval
      not_implemented(__method__)
    end
  end
end
