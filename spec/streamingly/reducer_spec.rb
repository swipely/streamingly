require 'spec_helper'

describe Streamingly::Reducer do

  let(:accumulator_class) { double }
  subject { described_class.new(accumulator_class) }

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
        accumulator_class.stub(:new).with(key) { accumulator }
      end

      it "combines them into the same accumulator" do
        accumulator.should_receive(:apply_value).with(value1)
        accumulator.should_receive(:apply_value).with(value2)

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
        accumulator_class.stub(:new).with(key1) { accumulator1 }
        accumulator_class.stub(:new).with(key2) { accumulator2 }
      end

      it "sends them to different accumulators" do
        accumulator1.should_receive(:apply_value).with(value1)
        accumulator2.should_receive(:apply_value).with(value2)

        subject.reduce_over(records)
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
        accumulator_class.stub(:new).with(key, accumulator_options) { accumulator }
      end

      it "uses the accumulator_options to initialize each accumulator" do
        accumulator.should_receive(:apply_value).with(value)

        subject.reduce_over(records)
      end
    end

  end

end
