# frozen_string_literal: true

require_relative '../lib/gem_model'

RSpec.describe GemModel do
  it 'is an alias of RubygemsCli::Gem for backward compatibility' do
    expect(GemModel).to eq(RubygemsCli::Gem)
  end

  describe '.build_collection' do
    it 'builds a collection of GemModel instances from hashes' do
      gems = GemModel.build_collection([
                                         { 'name' => 'rails', 'info' => 'Web framework', 'downloads' => 1000,
                                           'licenses' => ['MIT'] },
                                         { 'name' => 'faraday', 'info' => 'HTTP client' }
                                       ])

      expect(gems).to all(be_a(GemModel))
      expect(gems.map(&:name)).to eq(%w[rails faraday])
      expect(gems.first.downloads).to eq(1000)
      expect(gems.first.licenses).to eq(['MIT'])
      expect(gems.last.info).to eq('HTTP client')
    end
  end

  describe '#matches_name?' do
    it 'returns true when the gem name contains the keyword' do
      gem_model = GemModel.new({ 'name' => 'rails' })

      expect(gem_model.matches_name?('rail')).to be(true)
    end

    it 'returns false when the gem name does not contain the keyword' do
      gem_model = GemModel.new({ 'name' => 'faraday' })

      expect(gem_model.matches_name?('rails')).to be(false)
    end
  end

  describe '#matches_keyword?' do
    it 'returns true when keyword appears in gem info' do
      gem_model = GemModel.new({ 'name' => 'http-client', 'info' => 'Rails connector' })

      expect(gem_model.matches_keyword?('rails')).to be(true)
    end

    it 'returns false when keyword is in neither name nor info' do
      gem_model = GemModel.new({ 'name' => 'http-client', 'info' => 'REST helper' })

      expect(gem_model.matches_keyword?('rails')).to be(false)
    end
  end
end
