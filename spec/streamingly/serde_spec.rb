# encoding: utf-8
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

  describe ".from_tabbed_csv(string)" do
    context "given a string with a wide character" do
      let(:key) { [ "fonda-avenue-b-new-york", "62001" ] }
      let(:value) { [ "Sauvigñon Glass", "Item" ] }
      let(:line) { "#{key.join(',')}\t#{value.join(',')}".force_encoding("us-ascii") }

      it "correctly handles the input" do
        expect(described_class.from_tabbed_csv(line)).to eq(Streamingly::KV.new(key, value))
      end
    end
  end

end
