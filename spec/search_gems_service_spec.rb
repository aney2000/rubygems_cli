# frozen_string_literal: true

require_relative '../lib/search_gems_service'

RSpec.describe SearchGemsService do
  let(:api) { class_double(Api) }
  let(:cache) { class_double(Cache) }
  let(:service) { described_class.new(api: api, cache: cache) }

  it 'returns cached search results when present' do
    allow(cache).to receive(:read).with('search:rails').and_return([{ 'name' => 'rails' }])
    allow(api).to receive(:search_gems).and_return([])

    result = service.call('rails')

    expect(result).to eq([{ 'name' => 'rails' }])
    expect(api).not_to have_received(:search_gems)
  end

  it 'fetches from API and writes to cache when no cache exists' do
    allow(cache).to receive(:read).with('search:rails').and_return(nil)
    allow(api).to receive(:search_gems).with('rails').and_return([{ 'name' => 'rails' }])
    allow(cache).to receive(:write)

    result = service.call('rails')

    expect(result).to eq([{ 'name' => 'rails' }])
    expect(cache).to have_received(:write).with('search:rails', [{ 'name' => 'rails' }])
  end
end
