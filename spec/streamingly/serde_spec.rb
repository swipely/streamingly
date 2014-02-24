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

end