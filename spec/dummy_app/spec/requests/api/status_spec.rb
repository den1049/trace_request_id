# frozen_string_literal: true

require 'sidekiq/testing'

class LogStashTestFormatter < LogStashLogger::Formatter::JsonLines
  # rubocop:disable Lint/UselessMethodDefinition
  def format_event(event)
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition
end

Sidekiq::Testing.server_middleware do |chain|
  chain.add TraceRequestId::SidekiqServerMiddleware
  chain.add SidekiqLoggerMiddleware
end

RSpec.describe 'Api::Status', type: :request do
  describe 'GET /api/status' do
    let(:custom_trace_id) { 'custom-trace-123' }
    let(:test_formatter)  { LogStashTestFormatter.new }

    before do
      TraceRequestId.clear
    end

    context 'when controller logging its trace_id' do
      before do
        Rails.logger.formatter = test_formatter
        allow(test_formatter).to receive(:format_event).and_call_original
      end

      context 'when trace_is is not passed as header' do
        before do
          get '/api/status'
        end

        # rubocop:disable RSpec/MultipleExpectations
        it 'generates trace_id' do
          expect(test_formatter).to have_received(:format_event).at_least(:once) do |event|
            expect(event['trace_id']).to be_present
          end
        end
        # rubocop:enable RSpec/MultipleExpectations
      end

      context 'when trace_is is passed as header' do
        let(:custom_trace_id) { 'custom-trace-123' }

        before do
          get '/api/status', headers: { 'X-Request-ID' => custom_trace_id }
        end

        # rubocop:disable RSpec/MultipleExpectations
        it 'uses R-Request_Id as trace_id' do
          expect(test_formatter).to have_received(:format_event).at_least(:once) do |event|
            expect(event['trace_id']).to eq(custom_trace_id)
          end
        end
        # rubocop:enable RSpec/MultipleExpectations
      end
    end

    context 'when TestLoggerWorker logs trace_id chained from the controller' do
      before do
        Sidekiq::Worker.clear_all

        get '/api/status', headers: { 'X-Request-ID' => custom_trace_id }

        allow(Rails.logger).to receive(:info).and_call_original

        Rails.logger.formatter = test_formatter # Rails.logger.info from worker class
        allow(test_formatter).to receive(:format_event).and_call_original

        Sidekiq::Worker.drain_all
      end

      it 'executes TestLoggerWorker that calls Rails.logger.info' do
        expect(Rails.logger).to have_received(:info).with(
          hash_including(message: 'Test logging message', test_value: 'hello from status controller')
        ).at_least(:once)
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'includes trace_id in the logs from Sidekiq logger middleware' do
        expect(test_formatter).to have_received(:format_event).at_least(:once) do |event|
          if event['message'] == TestLoggerWorker.to_s
            expect(event.as_json).to match(hash_including('trace_id' => custom_trace_id))
          end
        end
      end

      it 'includes trace_id in the logs from worker logging call' do
        expect(test_formatter).to have_received(:format_event).at_least(:once) do |event|
          if event['message'] == 'Test logging message'
            expect(event.as_json).to match(hash_including('trace_id' => custom_trace_id))
          end
        end
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
