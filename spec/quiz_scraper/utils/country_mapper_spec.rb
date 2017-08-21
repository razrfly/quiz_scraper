require "spec_helper"

RSpec.describe QuizScraper::CountryMapper do
  let(:mapper) { QuizScraper::CountryMapper }
  let(:mapping) { mapper::MAPPINGS }

  it "should contain MAPPINGS constant" do
    expect(mapper.constants).to include(:MAPPINGS)
  end

  it "expects MAPPINGS constant to be an instance of Hash class" do
    expect(mapping).to be_an(Hash)
  end

  it "expects to respond_to singleton +map+ method" do
    expect(mapper.singleton_class.instance_methods).to include(:map)
  end

  it "expects to has one required argument for +map+ method" do
    expect(mapper.method(:map).arity).to eq(1)
  end

  it "expects to raise ArgumentError when no arguments given" do
    expect { mapper.map }.to raise_error(ArgumentError)
  end

  it "returns correct mapping for countries that were predefined" do
    expect(mapper.map('UK')).to eq('United Kingdom')
  end

  it "returns the same country for no-existing mapping" do
    expect(mapper.map('US')).to eq('US')
  end

  it "when expanded with additional mapping" do
    mapping.tap do |m|
      m.send(:[]=, ['America'], 'United States')
    end

    expect(mapper.map('America')).to eq('United States')
  end
end
