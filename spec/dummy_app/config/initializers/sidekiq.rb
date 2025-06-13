# frozen_string_literal: true

require './app/middleware/sidekiq_logger_middleware'

Sidekiq.logger.level = Logger::WARN
