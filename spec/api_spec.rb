# frozen_string_literal: true

require_relative '../lib/api'
require 'faraday'

RSpec.describe Api do
  describe '.connection' do
    around do |example|
      original_key = ENV.fetch('RUBYGEMS_API_KEY', nil)
      described_class.instance_variable_set(:@connection, nil)
      example.run
      ENV['RUBYGEMS_API_KEY'] = original_key
      described_class.instance_variable_set(:@connection, nil)
    end

    it 'adds the Authorization header when an API key is present' do
      ENV['RUBYGEMS_API_KEY'] = 'secret-token'

      connection = described_class.connection

      expect(connection.headers['Authorization']).to eq('secret-token')
    end

    it 'does not add the Authorization header when no API key is set' do
      ENV.delete('RUBYGEMS_API_KEY')

      connection = described_class.connection

      expect(connection.headers['Authorization']).to be_nil
    end
  end

  describe '.fetch_gem' do
    it 'returns a parsed hash when the gem exists' do
      response = instance_double(Faraday::Response, status: 200,
                                                    body: { 'name' => 'rails', 'info' => 'Web framework' }.to_json)
      connection = instance_double(Faraday::Connection, get: response)

      allow(described_class).to receive(:connection).and_return(connection)

      result = described_class.fetch_gem('rails')

      expect(result).to eq({ 'name' => 'rails', 'info' => 'Web framework' })
      expect(connection).to have_received(:get).with('gems/rails.json')
    end

    it 'returns nil when the gem is not found' do
      response = instance_double(Faraday::Response, status: 404, body: '')
      connection = instance_double(Faraday::Connection, get: response)

      allow(described_class).to receive(:connection).and_return(connection)

      result = described_class.fetch_gem('missing_gem')

      expect(result).to be_nil
      expect(connection).to have_received(:get).with('gems/missing_gem.json')
    end
  end

  describe '.search_gems' do
    it 'returns parsed results when the API responds successfully' do
      response = instance_double(Faraday::Response, status: 200, body: [{ 'name' => 'rails' }].to_json)
      connection = instance_double(Faraday::Connection, get: response)

      allow(described_class).to receive(:connection).and_return(connection)

      result = described_class.search_gems('rails')

      expect(result).to eq([{ 'name' => 'rails' }])
      expect(connection).to have_received(:get).with('search.json', { query: 'rails' })
    end

    it 'returns an empty array when the API responds with a non-200 status' do
      response = instance_double(Faraday::Response, status: 500, body: '')
      connection = instance_double(Faraday::Connection, get: response)

      allow(described_class).to receive(:connection).and_return(connection)

      result = described_class.search_gems('rails')

      expect(result).to eq([])
      expect(connection).to have_received(:get).with('search.json', { query: 'rails' })
    end
  end
end
