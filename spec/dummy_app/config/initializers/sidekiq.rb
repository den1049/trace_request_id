# frozen_string_literal: true

require './app/middleware/sidekiq_logger_middleware'

Sidekiq.logger.level = Logger::WARN

Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add TraceRequestId::SidekiqClientMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add TraceRequestId::SidekiqClientMiddleware
  end

  config.server_middleware do |chain|
    chain.add TraceRequestId::SidekiqServerMiddleware
    chain.add SidekiqLoggerMiddleware
  end
end
