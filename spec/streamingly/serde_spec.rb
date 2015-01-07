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

  describe '.to_csv' do
    it 'is identity function for a string' do
      record = 'test_string'
      expect(described_class.to_csv(record)).to eq record
    end

    it 'is equal to string version of Streamingly kv' do
      record = Streamingly::KV.new('key', 'value')
      expect(described_class.to_csv(record)).to eq record.to_s
    end

    it 'serializes struct to CSV, interpreting decimal fields as floats' do
      Record = Struct.new(:number, :string)
      record = Record.new(1, 'string_value')
      expect(described_class.to_csv(record)).to eq 'Record,1,string_value'
    end
  end

  describe '.from_string_or_csv' do
    it 'returns CSV serialization for CSV string' do
      expect(described_class.from_string_or_csv('1,2')).to eq ['1', '2']
    end

    it 'returns string if not containing a comma' do
      expect(described_class.from_string_or_csv('foo')).to eq 'foo'
    end

    it 'returns string if containing a comma but not valid CSV' do
      expect(described_class.from_string_or_csv('"foo,bar')).to eq '"foo,bar'
    end
  end
end