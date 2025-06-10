# frozen_string_literal: true

RSpec.describe TestLoggerWorker, type: :worker do
  let(:payload_hash) { { 'test_value' => 'hello world' } }

  before do
    allow(Rails.logger).to receive(:info).and_call_original
    described_class.new.perform(payload_hash)
  end

  it 'logs the test_value from payload_hash' do
    expect(Rails.logger).to have_received(:info).with(
      message:    'Test logging message',
      test_value: 'hello world'
    )
  end
end
