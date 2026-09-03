# frozen_string_literal: true

require_relative '../lib/gem'

RSpec.describe RubygemsCli::Gem do
  describe '.build_collection' do
    it 'builds Gem instances from API payload' do
      gems = described_class.build_collection([
                                                { 'name' => 'rails', 'info' => 'Web framework', 'downloads' => 1000,
                                                  'licenses' => ['MIT'] },
                                                { 'name' => 'faraday', 'info' => 'HTTP client' }
                                              ])

      expect(gems).to all(be_a(described_class))
      expect(gems.map(&:name)).to eq(%w[rails faraday])
      expect(gems.first.downloads).to eq(1000)
      expect(gems.first.licenses).to eq(['MIT'])
      expect(gems.last.info).to eq('HTTP client')
    end

    it 'applies defaults for missing downloads and licenses' do
      gem = described_class.new({ 'name' => 'faraday' })

      expect(gem.info).to eq('')
      expect(gem.downloads).to eq(0)
      expect(gem.licenses).to eq([])
    end
  end

  describe '#matches_name?' do
    it 'returns true when the gem name contains the keyword' do
      expect(described_class.new({ 'name' => 'rails' }).matches_name?('rail')).to be(true)
    end

    it 'returns false when the gem name does not contain the keyword' do
      expect(described_class.new({ 'name' => 'faraday' }).matches_name?('rails')).to be(false)
    end
  end

  describe '#matches_keyword?' do
    it 'matches keyword against name or info' do
      gem_model = described_class.new({ 'name' => 'http-client', 'info' => 'Rails connector' })

      expect(gem_model.matches_keyword?('rails')).to be(true)
      expect(gem_model.matches_keyword?('client')).to be(true)
      expect(gem_model.matches_keyword?('redis')).to be(false)
    end
  end
end
