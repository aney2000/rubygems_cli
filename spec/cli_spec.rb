# frozen_string_literal: true

require_relative '../cli'
require 'faraday'

RSpec.describe 'CLI Application' do
  it "displays 'Unknown command' for 'search' and returns false" do
    expect { 
      result = CLI.run(['search']) 
      expect(result).to be false
    }.to output(/Error: Unknown command 'search'/).to_stdout
  end

  it "displays 'Gem name required.' when show has no arguments and returns false" do
    expect { 
      result = CLI.run(['show']) 
      expect(result).to be false
    }.to output(/Error: Gem name required/).to_stdout
  end

  it "mocks API response, prints details, and returns true on success" do
    mock_json = { 'name' => 'faraday', 'info' => 'HTTP/REST API client library.' }.to_json
    
    allow(Faraday).to receive(:get).and_return(
      instance_double(Faraday::Response, status: 200, body: mock_json)
    )

    expect { 
      result = CLI.run(['show', 'faraday']) 
      expect(result).to be true
    }.to output(/GEM: faraday\nInfo: HTTP\/REST API client library\./).to_stdout
  end

  it "displays error and returns false when the gem is not found (404)" do
    allow(Faraday).to receive(:get).and_return(
      instance_double(Faraday::Response, status: 404, body: '')
    )

    expect { 
      result = CLI.run(['show', 'invalid_gem']) 
      expect(result).to be false
    }.to output(/Error: Gem 'invalid_gem' not found/).to_stdout
  end
end