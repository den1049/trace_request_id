# frozen_string_literal: true

class TraceRequestId
  class Railtie < Rails::Railtie # :nodoc:
    initializer 'trace_request_id.configure_rails_initialization' do |app|
      app.middleware.insert_after ActionDispatch::RequestId, Rack::TraceId
      register_sidekiq_middleware if defined?(Sidekiq)
    end

    private

    def register_sidekiq_middleware
      register_sidekiq_client_middleware
      register_sidekiq_server_middleware
    end

    def register_sidekiq_client_middleware
      Sidekiq.configure_client do |config|
        config.client_middleware do |chain|
          chain.add TraceRequestId::SidekiqClientMiddleware
        end
      end
    end

    def register_sidekiq_server_middleware
      Sidekiq.configure_server do |config|
        config.client_middleware do |chain|
          chain.add TraceRequestId::SidekiqClientMiddleware
        end

        config.server_middleware do |chain|
          chain.add TraceRequestId::SidekiqServerMiddleware
          chain.add SidekiqLoggerMiddleware
        end
      end
    end
  end
end
