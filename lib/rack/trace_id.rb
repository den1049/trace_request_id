# frozen_string_literal: true

require 'securerandom'

module Rack
  # Middleware to store +request_id+ in the thread context as +trace_id+ and clean it up at the end of the request.
  #
  # For rails app it needs to be inserted after ActionDispatch::RequestId to ensure that request_id
  # will be retrieved or generated with ActionDispatch::RequestId.
  #   config.middleware.insert_after ActionDispatch::RequestId, Rack::TraceId
  class TraceId
    def initialize(app)
      @app = app
    end

    def call(env)
      with_trace_id(env) do
        @app.call(env)
      end
    end

    private

    # Extracts +request_id+ from +env+ argument, then wraps block with thread context store and clear steps
    def with_trace_id(env)
      TraceRequestId.id = env_request_id(env)

      yield
    ensure
      TraceRequestId.clear
    end

    def env_request_id(env)
      return env['HTTP_X_REQUEST_ID'] || SecureRandom.uuid unless defined?(ActionDispatch::Request)

      # extract request_id assigned by ActionDispatch::RequestId middleware
      req = ActionDispatch::Request.new env
      req.request_id
    end
  end
end
