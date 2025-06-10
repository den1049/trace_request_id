# frozen_string_literal: true

require 'securerandom'

require_relative 'trace_request_id/version'
require_relative 'trace_request_id/rails_middleware' if defined?(Rails)
require_relative 'trace_request_id/sidekiq_client_middleware' if defined?(Sidekiq)
require_relative 'trace_request_id/sidekiq_server_middleware' if defined?(Sidekiq)

# Module to store trace id in the thread context
class TraceRequestId
  TRACE_ID = '__trace_id'

  class << self
    # Get the current trace id, or +nil+ if one has not been set.
    def id(init: false)
      self.id = new_trace_id_value if init && current_trace_id.to_s.strip.empty?

      current_trace_id
    end

    # Set the new trace id.
    def id=(new_trace_id)
      Thread.current.thread_variable_set(TRACE_ID, new_trace_id)
    end

    # Clear the trace id from the current thread.
    def clear
      Thread.current.thread_variable_set(TRACE_ID, nil)
    end

    private

    def current_trace_id
      Thread.current.thread_variable_get(TRACE_ID)
    end

    def new_trace_id_value
      SecureRandom.uuid
    end
  end
end
