# frozen_string_literal: true

class TraceRequestId
  # Restores +trace_id+ from the job context (Redis) to the thread context before starting a job.
  #
  # It needs to be inserted in the SidekiqClient chain at the start.
  #   Sidekiq.configure_server do |config|
  #     config.server_middleware do |chain|
  #       chain.add TraceRequestId::SidekiqServerMiddleware
  #       # ... other server middlewares
  #     end
  #   end
  class SidekiqServerMiddleware
    def call(_worker, job, _queue)
      TraceRequestId.id = job[TraceRequestId::TRACE_ID]

      yield
    ensure
      TraceRequestId.clear
    end
  end
end
