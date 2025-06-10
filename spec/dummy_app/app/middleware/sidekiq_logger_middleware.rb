# frozen_string_literal: true

# Middleware for writing job logs to Kibana categorizer-job-* index
class SidekiqLoggerMiddleware
  attr_reader :worker

  def call(worker, _message, _queue, &_block)
    @worker = worker

    yield
  ensure
    Rails.logger.info({ message: worker.class.to_s })
  end
end
