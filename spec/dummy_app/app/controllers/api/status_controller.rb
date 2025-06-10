# frozen_string_literal: true

module Api
  # controller for testing test_id logging
  class StatusController < ApplicationController
    def index
      TestLoggerWorker.perform_async({ 'test_value' => 'hello from status controller' })
      render json: {
        status:    'ok',
        trace_id:  TraceRequestId.id,
        timestamp: Time.current
      }
    end
  end
end
