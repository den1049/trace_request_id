# frozen_string_literal: true

class TraceRequestId
  # Stores +trace_id+ from the thread context to the job context before saving it to Redis.
  #
  # It needs to be inserted in the SidekiqClient chain at the start.
  #   Sidekiq.configure_client do |config|
  #     config.client_middleware do |chain|
  #       chain.add TraceRequestId::SidekiqClientMiddleware
  #       # ... other client middlewares
  #     end
  #   end
  #
  #   Sidekiq.configure_server do |config|
  #     config.client_middleware do |chain|
  #       chain.add TraceRequestId::SidekiqClientMiddleware
  #       # ... other client middlewares
  #     end
  #   end
  class SidekiqClientMiddleware
    def call(_worker_class, job, _queue, _redis_pool = '')
      job[TraceRequestId::TRACE_ID] = TraceRequestId.id(init: true)
      yield
    end
  end
end
