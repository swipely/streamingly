require 'spec_helper'

class TestAccumulator
  attr_reader :applied_values, :raised_errors, :error_contexts

  def initialize
    @applied_values = []
    @raised_errors = []
    @error_contexts = []
  end

  def apply_value(value)
    @applied_values << value
  end

  def flush
    []
  end

  def on_error(error, error_context)
    @raised_errors << error
    @error_contexts << error_context
  end
end

class RaisesOnSingleCharAccumulator < TestAccumulator
  def apply_value(value)
    super(value)
    raise ArgumentError, "Must not be a single character" if value.size == 1
  end
end

class RaisesOnFlushAccumulator < TestAccumulator
  def flush
    raise RuntimeError, "Cannot flush when ya only have two pairs"
  end
end

describe Streamingly::Reducer do

  let(:accumulator_class) { double(:accumulator_class, :method_defined? => true) }
  subject { described_class.new(accumulator_class) }

  describe '#on_error' do
    it 'is exposed as public method' do
      expect(subject).to respond_to(:on_error)
    end
  end

  describe "#reduce_over" do

    context "given records with the same key" do
      let(:key) { 'key' }
      let(:value1) { 'asdf' }
      let(:value2) { 'qwerty' }

      let(:records) {
        [
          [key, value1].join("\t"),
          [key, value2].join("\t")
        ]
      }

      let(:accumulator) { double(:accumulator, :flush => []) }

      before do
        allow(accumulator_class).to \
          receive(:new).with(key).and_return(accumulator)
      end

      it "combines them into the same accumulator" do
        expect(accumulator).to receive(:apply_value).with(value1)
        expect(accumulator).to receive(:apply_value).with(value2)

        subject.reduce_over(records)
      end
    end

    context "given records with different keys" do
      let(:key1) { 'key1' }
      let(:key2) { 'key2' }
      let(:value1) { 'asdf' }
      let(:value2) { 'qwerty' }

      let(:records) {
        [
          [key1, value1].join("\t"),
          [key2, value2].join("\t")
        ]
      }

      let(:accumulator1) { double(:accumulator, :flush => []) }
      let(:accumulator2) { double(:accumulator, :flush => []) }

      before do
        allow(accumulator_class).to \
          receive(:new).with(key1).and_return(accumulator1)
        allow(accumulator_class).to \
          receive(:new).with(key2).and_return(accumulator2)
      end

      it "sends them to different accumulators" do
        expect(accumulator1).to receive(:apply_value).with(value1)
        expect(accumulator2).to receive(:apply_value).with(value2)

        subject.reduce_over(records)
      end
    end

    context "given a record with multiple tabs" do
      let(:key) { 'key1' }
      let(:value) { "asdf\tqwerty" }

      let(:records) {
        [
          [key, value].join("\t"),
        ]
      }

      let(:accumulator) { double(:accumulator, :flush => []) }

      before do
        allow(accumulator_class).to \
          receive(:new).with(key).and_return(accumulator)
      end

      it "treats only the first tab as the key/value delimiter and leaves the value untouched" do
        expect(accumulator).to receive(:apply_value).with(value)

        subject.reduce_over(records)
      end
    end

    context "given a record which will cause an exception" do
      let(:key) { 'key1' }
      let(:value1) { "a" }
      let(:value2) { "abc" }
      let(:records) {
        [
          [key, value1].join("\t"),
          [key, value2].join("\t")
        ]
      }

      let(:accumulator) { RaisesOnSingleCharAccumulator.new }

      context "with error callback specified" do
        before do
          allow(accumulator_class).to \
            receive(:new).with(key).and_return(accumulator)
        end

        it "keeps processing after error applying value" do
          subject.reduce_over(records)

          expect(accumulator.applied_values).to eq([value1, value2])
        end

        it "calls supplied error callback with correct context" do
          subject.reduce_over(records)

          expect(accumulator.raised_errors.size).to eq(1)
          raised_error = accumulator.raised_errors[0]
          expect(raised_error.class).to eq(ArgumentError)

          expect(accumulator.error_contexts.size).to eq(1)
          error_context = accumulator.error_contexts[0]
          expect(error_context[:line]).to eq([key, value1].join("\t"))
        end
      end

      context "without error callback specified" do
        let(:accumulator_class) { double(:accumulator_class, :method_defined? => false) }
        subject { described_class.new(accumulator_class) }

        before do
          allow(accumulator_class).to \
            receive(:new).with(key).and_return(accumulator)
        end

        it "stops processing after error applying value" do
          expect{ subject.reduce_over(records) }.to raise_error(ArgumentError)

          expect(accumulator.applied_values).to eq([value1])
          expect(accumulator.raised_errors.size).to eq(0)
        end
      end
    end

    context "given accumulator which fails on flush" do
      let(:key1) { 'key1' }
      let(:key2) { 'key2' }
      let(:value1) { 'asdf' }
      let(:value2) { 'qwerty' }

      let(:records) {
        [
          [key1, value1].join("\t"),
          [key2, value2].join("\t")
        ]
      }

      let(:accumulator1) { RaisesOnFlushAccumulator.new }
      let(:accumulator2) { TestAccumulator.new }

      context "with error callback specified" do
        before do
          allow(accumulator_class).to \
            receive(:new).with(key1).and_return(accumulator1)
          allow(accumulator_class).to \
            receive(:new).with(key2).and_return(accumulator2)
        end

        it "keeps processing after error applying value" do
          subject.reduce_over(records)

          expect(accumulator1.applied_values).to eq([value1])

          expect(accumulator2.applied_values).to eq([value2])
        end

        it "calls supplied error callback" do
          subject.reduce_over(records)

          expect(accumulator1.raised_errors.size).to eq(1)
          raised_error = accumulator1.raised_errors[0]
          expect(raised_error.class).to eq(RuntimeError)

          expect(accumulator1.error_contexts.size).to eq(1)
          expect(accumulator1.error_contexts[0]).to be_empty

          expect(accumulator2.raised_errors.size).to eq(0)
        end
      end

      context "without error callback specified" do
        let(:accumulator_class) { double(:accumulator_class, :method_defined? => false) }
        subject { described_class.new(accumulator_class) }

        before do
          allow(accumulator_class).to \
            receive(:new).with(key1).and_return(accumulator1)
          allow(accumulator_class).to \
            receive(:new).with(key2).and_return(accumulator2)
        end

        it "stops processing after error applying value" do
          expect{ subject.reduce_over(records) }.to raise_error(RuntimeError)

          expect(accumulator1.applied_values).to eq([value1])
          expect(accumulator1.raised_errors.size).to eq(0)

          expect(accumulator2.applied_values).to eq([])
          expect(accumulator2.raised_errors.size).to eq(0)
        end
      end
    end

    context "when supplied with accumulator options" do
      let(:accumulator_options) { { foo: 'bar' } }
      subject { described_class.new(accumulator_class, accumulator_options) }

      let(:key) { 'key' }
      let(:value) { 'asdf' }

      let(:records) {
        [
          [key, value].join("\t")
        ]
      }

      let(:accumulator) { double(:accumulator, :flush => []) }

      before do
        allow(accumulator_class).to \
          receive(:new).with(key, accumulator_options).and_return(accumulator)
      end

      it "uses the accumulator_options to initialize each accumulator" do
        expect(accumulator).to receive(:apply_value).with(value)

        subject.reduce_over(records)
      end
    end

  end

end
