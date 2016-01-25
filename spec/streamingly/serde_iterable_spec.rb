require 'spec_helper'

describe Streamingly::SerDeIterable do
  let(:iterable) { [1] }
  let(:error) { StandardError.new('error') }

  before do
    allow(Streamingly::SerDe).to receive(:from_tabbed_csv).and_raise(error)
  end

  describe 'no error handler given' do
    subject { described_class.new(iterable) }

    it 'raises error when calling each' do
      expect { subject.each }.to raise_error
    end
  end

  describe 'given custom error handler' do
    let(:error_handler) { double(:error_handler, method_defined?: true) }
    subject { described_class.new(iterable, error_handler) }

    it 'calls on_error method of provided handler' do
      expect(error_handler).to receive(:on_error).with(error, line: 1)
      expect { subject.each }.to_not raise_error
    end
  end
end
