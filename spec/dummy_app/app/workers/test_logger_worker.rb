# frozen_string_literal: true

# worker for testing trace_id passing from the controller
class TestLoggerWorker
  include Sidekiq::Worker

  def perform(payload_hash)
    Rails.logger.info(
      message:    'Test logging message',
      test_value: payload_hash['test_value']
    )
  end
end
