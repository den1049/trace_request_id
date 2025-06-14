# frozen_string_literal: true

class LogStashTestFormatter < LogStashLogger::Formatter::JsonLines
  # rubocop:disable Lint/UselessMethodDefinition
  def format_event(event)
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition
end

RSpec.describe 'Api::Status', type: :request do
  describe 'GET /api/status' do
    let(:custom_trace_id) { 'custom-trace-123' }
    let(:test_formatter)  { LogStashTestFormatter.new }

    before do
      TraceRequestId.clear
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
      it 'uses X-Request_Id as trace_id' do
        expect(test_formatter).to have_received(:format_event).at_least(:once) do |event|
          expect(event['trace_id']).to eq(custom_trace_id)
        end
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
