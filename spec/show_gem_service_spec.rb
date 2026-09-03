# frozen_string_literal: true

require_relative '../lib/show_gem_service'

RSpec.describe ShowGemService do
  let(:api) { class_double('Api') }
  let(:cache) { class_double('Cache') }
  let(:service) { described_class.new(api: api, cache: cache) }

  it 'returns cached gem details when present' do
    allow(cache).to receive(:read).with('gem:rails').and_return({ 'name' => 'rails' })

    result = service.call('rails')

    expect(result).to eq({ 'name' => 'rails' })
    expect(api).not_to have_received(:fetch_gem)
  end

  it 'fetches and caches gem details when cache is missing' do
    allow(cache).to receive(:read).with('gem:rails').and_return(nil)
    allow(api).to receive(:fetch_gem).with('rails').and_return({ 'name' => 'rails' })
    allow(cache).to receive(:write)

    result = service.call('rails')

    expect(result).to eq({ 'name' => 'rails' })
    expect(cache).to have_received(:write).with('gem:rails', { 'name' => 'rails' })
  end
end
