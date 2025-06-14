# frozen_string_literal: true

class ApplicationController < Sinatra::Base
  use Rack::TraceId

  get '/status' do
    {
      message:  'Hello, World!',
      trace_id: TraceRequestId.id
    }.to_json
  end
end
