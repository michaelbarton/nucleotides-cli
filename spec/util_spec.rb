require 'nucleotides/util'

RSpec.describe Nucleotides::Util do

  describe "#subcommand" do

    it "should the expected class when available" do
      expect(described_class.subcommand("fetch-data")).to eq(Nucleotides::FetchData)
    end

  end

  describe "#missing_arguments" do

    let(:required) do
      [:a, :b, :c]
    end

    let(:given) do
      {a: 1, b: 2, c: 3}
    end

    it "should return an empty array given required options" do
      expect(described_class.missing_options(required, given)).to be_empty
    end

    it "should return an empty array given all required options plus given optional options" do
      expect(described_class.missing_options(required, given.merge({x: 26}))).to be_empty
    end

    it "should return an empty array given all required options plus missing optional options" do
      expect(described_class.missing_options(required, given.merge({x: nil}))).to be_empty
    end

    it "should return an array containing options they are missing" do
      missing = given.clone
      missing[:c] = nil
      expect(described_class.missing_options(required, missing)).to eq([:c])
    end

  end

end
