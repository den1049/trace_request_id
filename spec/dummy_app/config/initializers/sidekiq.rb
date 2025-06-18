# frozen_string_literal: true

require './app/middleware/sidekiq_logger_middleware'

Sidekiq.logger.level = Logger::WARN

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqLoggerMiddleware
  end
end
