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