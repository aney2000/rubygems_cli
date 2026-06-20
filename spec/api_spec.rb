# frozen_string_literal: true

require_relative '../lib/api'
require 'faraday'

RSpec.describe Api do
  describe '.fetch_gem' do
    it 'returns a parsed hash when the gem exists (status 200)' do
      mock_json = { 'name' => 'rails', 'info' => 'Web framework' }.to_json
      
      allow(Faraday).to receive(:get).and_return(
        instance_double(Faraday::Response, status: 200, body: mock_json)
      )

      result = Api.fetch_gem('rails')
      expect(result).to eq({ 'name' => 'rails', 'info' => 'Web framework' })
    end

    it 'returns nil when the gem is not found (status 404)' do
      allow(Faraday).to receive(:get).and_return(
        instance_double(Faraday::Response, status: 404, body: '')
      )

      result = Api.fetch_gem('nonexistent_gem')
      expect(result).to be_nil
    end
  end
end