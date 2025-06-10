# frozen_string_literal: true

require 'trace_request_id'
require 'securerandom'

RSpec.describe TraceRequestId do
  it 'has a version number' do
    expect(TraceRequestId::VERSION).not_to be_nil
  end

  describe '.id' do
    context 'when no trace id is set' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return('test-uuid')
      end

      it 'returns nil' do
        expect(described_class.id).to be_nil
      end

      context 'with init: true' do
        it 'generates and returns a new UUID' do
          expect(described_class.id(init: true)).to eq('test-uuid')
        end

        it 'stores the generated UUID in thread context' do
          described_class.id(init: true)
          expect(Thread.current.thread_variable_get(described_class::TRACE_ID)).to match('test-uuid')
        end
      end
    end

    context 'when trace id is already set' do
      let(:existing_id) { 'existing-uuid' }

      before do
        described_class.id = existing_id
      end

      it 'returns the existing id' do
        expect(described_class.id).to eq(existing_id)
      end

      context 'with init: true' do
        it 'keeps the existing id' do
          expect(described_class.id(init: true)).to eq(existing_id)
        end
      end
    end
  end

  describe '.id=' do
    let(:new_id) { 'new-uuid' }

    it 'sets the trace id in thread context' do
      described_class.id = new_id
      expect(Thread.current.thread_variable_get(described_class::TRACE_ID)).to eq(new_id)
    end

    it 'allows retrieving the set id' do
      described_class.id = new_id
      expect(described_class.id).to eq(new_id)
    end
  end

  describe 'thread isolation' do
    let(:first_thread) { Thread.new { described_class.id = 'thread1-uuid' } }
    let(:second_thread) { Thread.new { described_class.id = 'thread2-uuid' } }

    let(:expected_result) do
      {
        first:   'thread1-uuid',
        second:  'thread2-uuid',
        current: nil
      }
    end

    before do
      described_class.clear
    end

    after do
      described_class.clear
    end

    it 'maintains separate trace ids for different threads' do
      first_thread.join
      second_thread.join

      result = {
        first:   first_thread.thread_variable_get(described_class::TRACE_ID),
        second:  second_thread.thread_variable_get(described_class::TRACE_ID),
        current: described_class.id
      }

      expect(result).to eq(expected_result)
    end
  end
end
