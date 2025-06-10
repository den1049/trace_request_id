# frozen_string_literal: true

module Api
  # controller for testing test_id logging
  class StatusController < ApplicationController
    def index
      render json: {
        status:    'ok',
        trace_id:  TraceRequestId.id,
        timestamp: Time.current
      }
    end
  end
end
