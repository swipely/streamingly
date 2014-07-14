require 'spec_helper'

describe Streamingly::SerDe do

  describe ".from_csv" do
    let(:value) { '19' }
    let(:text) { "#{type.name},#{value}" }

    context "given a namespaced class" do
      before do
        Namespace = Module.new
        Namespace::Namespaced = Struct.new(:value)
      end

      let(:type) { Namespace::Namespaced }

      it { expect(described_class.from_csv(text)).to eq(type.new(value)) }
    end

    context "given a non-namespaced class" do
      before do
        NonNamespaced = Struct.new(:value)
      end

      let(:type) { NonNamespaced }

      it { expect(described_class.from_csv(text)).to eq(type.new(value)) }
    end
  end

  describe ".from_tabbed_csv" do
    SampleKey = Struct.new(
      :id
    )

    SampleVal = Struct.new(
      :val1,
      :val2
    )

    context "converting a csv" do

      subject { Streamingly::SerDe.from_tabbed_csv "SampleKey,id\tSampleVal,one,two" }

      it "should have a key" do
        expect(subject.key).to be_a SampleKey
        expect(subject.key.id).to eql "id"
      end

      it "should have a value" do
        expect(subject.value).to be_a SampleVal
        expect(subject.value.val1).to eql "one"
        expect(subject.value.val2).to eql "two"
      end
    end

    context "converting a csv with extra tabs" do

      subject { Streamingly::SerDe.from_tabbed_csv "SampleKey,id\tSampleVal,one \t \t,two \t" }

      it "should have a key" do
        expect(subject.key).to be_a SampleKey
        expect(subject.key.id).to eql "id"
      end

      it "should have a value" do
        expect(subject.value).to be_a SampleVal
        expect(subject.value.val1).to eql "one \t \t"
        expect(subject.value.val2).to eql "two \t"
      end
    end
  end

end
