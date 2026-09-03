# frozen_string_literal: true

require_relative '../lib/gem_search'
require_relative '../lib/gem_model'

RSpec.describe GemSearch do
  it 'keeps name matches before info-only matches' do
    gems = GemModel.build_collection([
                                       { 'name' => 'rails-admin', 'info' => 'dashboard', 'downloads' => 1, 'licenses' => ['MIT'] },
                                       { 'name' => 'admin-kit', 'info' => 'works with rails', 'downloads' => 100, 'licenses' => ['MIT'] }
                                     ])

    results = GemSearch.new(gems, query: 'rails').results

    expect(results.map(&:name)).to eq(%w[rails-admin admin-kit])
  end

  it 'applies license filter and downloads sorting together' do
    gems = GemModel.build_collection([
                                       { 'name' => 'rails-a', 'info' => '', 'downloads' => 1, 'licenses' => ['MIT'] },
                                       { 'name' => 'rails-b', 'info' => '', 'downloads' => 5, 'licenses' => ['MIT'] },
                                       { 'name' => 'rails-c', 'info' => '', 'downloads' => 9, 'licenses' => ['Apache-2.0'] }
                                     ])

    results = GemSearch.new(gems, query: 'rails', license: 'MIT', most_downloads_first: true).results

    expect(results.map(&:name)).to eq(%w[rails-b rails-a])
  end
end
