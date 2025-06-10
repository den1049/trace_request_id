# frozen_string_literal: true

LogStashLogger.configure do |config|
  config.customize_event do |event|
    event['service']  = 'errors' unless event['service'] || event[:service]
    event['project']  = 'dummy_app'
    event['trace_id'] = TraceRequestId.id
  end
end
