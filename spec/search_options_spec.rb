# frozen_string_literal: true

require_relative '../lib/search_options'

RSpec.describe SearchOptions do
  describe '.parse' do
    it 'returns an error when no query is provided' do
      result = SearchOptions.parse([])

      expect(result.error).to eq('Search keyword required.')
    end

    it 'parses both supported options' do
      result = SearchOptions.parse(%w[rails --license MIT --most-downloads-first])

      expect(result.query).to eq('rails')
      expect(result.license).to eq('MIT')
      expect(result.most_downloads_first).to be(true)
      expect(result.error).to be_nil
    end

    it 'parses aliases for options' do
      result = SearchOptions.parse(%w[rspec --licence MIT --recent-first])

      expect(result.query).to eq('rspec')
      expect(result.license).to eq('MIT')
      expect(result.most_downloads_first).to be(true)
      expect(result.error).to be_nil
    end

    it 'returns an error for unknown options' do
      result = SearchOptions.parse(%w[rails --unknown])

      expect(result.error).to eq("Unknown option '--unknown'.")
    end

    it 'returns an error when --license has no value' do
      result = SearchOptions.parse(%w[rails --license])

      expect(result.error).to eq('Missing value for --license.')
    end
  end
end
