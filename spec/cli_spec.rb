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
  end

  it "displays 'Gem name required.' when show has no arguments and exits" do
    expect do
      expect { CLI.run(['show']) }.to raise_error(SystemExit)
    end.to output(/Error: Gem name required/).to_stdout
  end

  it 'prints gem details and exits successfully for show' do
    allow(Api).to receive(:fetch_gem).and_return({ 'name' => 'faraday', 'info' => 'HTTP/REST API client library.' })

    expect do
      expect { CLI.run(%w[show faraday]) }.to raise_error(SystemExit)
    end.to output(%r{GEM: faraday\nInfo: HTTP/REST API client library\.}).to_stdout
  end

  it 'displays an error and exits when the gem is not found' do
    allow(Api).to receive(:fetch_gem).and_return(nil)

    expect do
      expect { CLI.run(%w[show invalid_gem]) }.to raise_error(SystemExit)
    end.to output(/Error: Gem 'invalid_gem' not found/).to_stdout
  end

  it 'prints search results from the API when the cache is empty' do
    allow(Cache).to receive(:read).and_return(nil)
    allow(Api).to receive(:search_gems).and_return([{ 'name' => 'rails', 'info' => 'Web framework' }])
    allow(Cache).to receive(:write)

    expect do
      expect { CLI.run(%w[search rails]) }.to raise_error(SystemExit)
    end.to output(/GEM: rails\nInfo: Web framework/).to_stdout
  end
end
