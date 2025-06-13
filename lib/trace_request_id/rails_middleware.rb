# frozen_string_literal: true

class TraceRequestId
  # Middleware to store +request_id+ in the thread context as +trace_id+ and clean it up at the end of the request.
  #
  # It needs to be inserted after ActionDispatch::RequestId to ensure that request_id
  # will be either retrieved from +X-Request-Id+ or newly generated.
  #   config.middleware.insert_after ActionDispatch::RequestId, TraceRequestId::RailsMiddleware
  class RailsMiddleware
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
      req = ActionDispatch::Request.new env # extract request_id assigned by ActionDispatch::RequestId middleware
      TraceRequestId.id = req.request_id

      yield
    ensure
      TraceRequestId.clear
    end
  end
end
