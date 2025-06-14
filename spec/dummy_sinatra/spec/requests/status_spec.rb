# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/controllers/application_controller'

RSpec.describe 'Api::Status', type: :request do
  describe 'GET /api/status' do
    let(:app)             { ApplicationController.new }
    let(:default_host)    { 'localhost' }

    before do
      TraceRequestId.clear
    end

    context 'when trace_is is not passed as header' do
      before do
        get '/status'
      end

      it 'responds with 200 OK' do
        expect(last_response).to be_ok
      end

      it 'generates trace_id' do
        response_body = JSON.parse(last_response.body)
        expect(response_body['trace_id']).to be_a_uuid
      end
    end

    context 'when trace_is is passed as header' do
      let(:custom_trace_id) { 'custom-trace-123' }
      let(:respond) do
        {
          'message'  => 'Hello, World!',
          'trace_id' => custom_trace_id
        }
      end

      before do
        header 'X-Request-Id', custom_trace_id
        get 'status'
      end

      it 'responds with 200 OK' do
        expect(last_response).to be_ok
      end

      it 'uses X-Request_Id as trace_id' do
        expect(JSON.parse(last_response.body)).to eq(respond)
      end
    end
  end
end
