# frozen_string_literal: true

require_relative '../lib/api'
require 'faraday'

RSpec.describe Api do
  let(:body) { { 'name' => 'rails', 'info' => 'Web framework' } }
  let(:status) { 200 }
  let(:response) { instance_double(Faraday::Response, status: status, body: body.to_json) }
  let(:connection) { instance_double(Faraday::Connection, get: response) }

  before do
    allow(Api).to receive(:connection).and_return(connection)
    allow(connection).to receive(:get).and_return(response)
  end

  describe '.fetch_gem' do
    it 'returns a parsed hash when the gem exists' do
      result = Api.fetch_gem('rails')

      expect(result).to eq({ 'name' => 'rails', 'info' => 'Web framework' })
      expect(connection).to have_received(:get).with('gems/rails.json')
    end

    context 'response body is empty' do
      let(:status) { 404 }

      it 'returns nil when the gem is not found' do
        result = Api.fetch_gem('missing_gem')

        expect(result).to be_nil
        expect(connection).to have_received(:get).with('gems/missing_gem.json')
      end
    end
  end


  describe '.search_gems' do
    let(:body) { [{ 'name' => 'rails' }] }

    it 'returns parsed results when the API responds successfully' do
      result = Api.search_gems('rails')

      expect(result).to eq([{ 'name' => 'rails' }])
      expect(connection).to have_received(:get).with('search.json', { query: 'rails' })
    end

    context 'when the API responds with a non-200 status' do
      let(:status) { 500 }

      it 'returns an empty array' do
        result = Api.search_gems('rails')

        expect(result).to eq([])
        expect(connection).to have_received(:get).with('search.json', { query: 'rails' })
      end
    end
  end

  describe '.connection' do
    around do |example|
      original_key = ENV['RUBYGEMS_API_KEY']
      Api.instance_variable_set(:@connection, nil)
      example.run
      ENV['RUBYGEMS_API_KEY'] = original_key
      Api.instance_variable_set(:@connection, nil)
    end

    before do
      allow(Api).to receive(:connection).and_call_original
    end

    it 'adds the Authorization header when an API key is present' do
      ENV['RUBYGEMS_API_KEY'] = 'secret-token'

      connection = Api.connection

      expect(connection.headers['Authorization']).to eq('secret-token')
    end

    it 'does not add the Authorization header when no API key is set' do
      ENV.delete('RUBYGEMS_API_KEY')

      connection = Api.connection

      expect(connection.headers['Authorization']).to be_nil
    end
  end
end

