# frozen_string_literal: true

require_relative '../cli'
require 'faraday'

RSpec.describe 'CLI Application' do
  before do
    allow(CLI).to receive(:exit).and_raise(SystemExit)
  end

  it "displays 'Search keyword required.' for 'search' and exits" do
    expect do
      expect { CLI.run(['search']) }.to raise_error(SystemExit)
    end.to output(/Error: Search keyword required\./).to_stdout

    expect(CLI).to have_received(:exit).with(1)
  end

  it "displays 'Gem name required.' when show has no arguments and exits" do
    expect do
      expect { CLI.run(['show']) }.to raise_error(SystemExit)
    end.to output(/Error: Gem name required/).to_stdout

    expect(CLI).to have_received(:exit).with(1)
  end

  it 'prints gem details and exits successfully for show' do
    allow(Cache).to receive(:read).with('gem:faraday').and_return(nil)
    allow(Cache).to receive(:write)
    allow(Api).to receive(:fetch_gem).and_return({ 'name' => 'faraday', 'info' => 'HTTP/REST API client library.' })

    expect do
      expect { CLI.run(%w[show faraday]) }.to raise_error(SystemExit)
    end.to output(%r{GEM: faraday\nInfo: HTTP/REST API client library\.}).to_stdout

    expect(Cache).to have_received(:write).with('gem:faraday', hash_including('name' => 'faraday'))
    expect(CLI).to have_received(:exit).with(0)
  end

  it 'displays an error and exits when the gem is not found' do
    allow(Cache).to receive(:read).with('gem:invalid_gem').and_return(nil)
    allow(Api).to receive(:fetch_gem).and_return(nil)

    expect do
      expect { CLI.run(%w[show invalid_gem]) }.to raise_error(SystemExit)
    end.to output(/Error: Gem 'invalid_gem' not found/).to_stdout

    expect(CLI).to have_received(:exit).with(1)
  end

  it 'uses cache for show and skips API call when entry is fresh' do
    allow(Cache).to receive(:read).with('gem:faraday').and_return({ 'name' => 'faraday', 'info' => 'cached info' })
    allow(Api).to receive(:fetch_gem)

    expect do
      expect { CLI.run(%w[show faraday]) }.to raise_error(SystemExit)
    end.to output(%r{GEM: faraday\nInfo: cached info}).to_stdout

    expect(Api).not_to have_received(:fetch_gem)
    expect(CLI).to have_received(:exit).with(0)
  end

  it 'prints search results from the API when the cache is empty' do
    allow(Cache).to receive(:read).with('search:rails').and_return(nil)
    allow(Api).to receive(:search_gems).and_return([{ 'name' => 'rails', 'info' => 'Web framework' }])
    allow(Cache).to receive(:write)

    expect do
      expect { CLI.run(%w[search rails]) }.to raise_error(SystemExit)
    end.to output(/GEM: rails\nInfo: Web framework/).to_stdout

    expect(Cache).to have_received(:write).with('search:rails', [hash_including('name' => 'rails')])
  end

  it 'supports combined --license and --most-downloads-first options' do
    allow(Cache).to receive(:read).with('search:ruby').and_return(nil)
    allow(Cache).to receive(:write)
    allow(Api).to receive(:search_gems).and_return([
                                                     { 'name' => 'ruby_core', 'info' => 'official ruby lib', 'downloads' => 3,
                                                       'licenses' => ['MIT'] },
                                                     { 'name' => 'irb-helper', 'info' => 'ruby shell helper', 'downloads' => 7,
                                                       'licenses' => ['MIT'] },
                                                     { 'name' => 'rubyx', 'info' => 'ruby extension', 'downloads' => 10,
                                                       'licenses' => ['Apache-2.0'] }
                                                   ])

    expect do
      expect { CLI.run(%w[search ruby --license MIT --most-downloads-first]) }.to raise_error(SystemExit)
    end.to output(/GEM: ruby_core.*GEM: irb-helper/m).to_stdout
  end

  it 'supports aliases --licence and --recent-first' do
    allow(Cache).to receive(:read).with('search:rspec').and_return(nil)
    allow(Cache).to receive(:write)
    allow(Api).to receive(:search_gems).and_return([
                                                     { 'name' => 'rspec-core', 'info' => 'rspec', 'downloads' => 1,
                                                       'licenses' => ['MIT'] },
                                                     { 'name' => 'my-rspec-tools', 'info' => 'rspec helpers', 'downloads' => 2,
                                                       'licenses' => ['MIT'] }
                                                   ])

    expect do
      expect { CLI.run(%w[search rspec --licence MIT --recent-first]) }.to raise_error(SystemExit)
    end.to output(/GEM: my-rspec-tools.*GEM: rspec-core/m).to_stdout
  end

  it 'returns an error for unknown options' do
    expect do
      expect { CLI.run(%w[search rails --unknown]) }.to raise_error(SystemExit)
    end.to output(/Error: Unknown option '--unknown'\./).to_stdout

    expect(CLI).to have_received(:exit).with(1)
  end

  it 'returns an error when --license is provided without value' do
    expect do
      expect { CLI.run(%w[search rails --license]) }.to raise_error(SystemExit)
    end.to output(/Error: Missing value for --license\./).to_stdout

    expect(CLI).to have_received(:exit).with(1)
  end
end
