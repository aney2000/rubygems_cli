# frozen_string_literal: true

require 'faraday'
require 'json'

class Api
  private
  BASE_URL = 'https://rubygems.org/api/v1'

  def self.connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      api_key = ENV['RUBYGEMS_API_KEY']

      conn.headers['Authorization'] = api_key if api_key && !api_key.empty?
      conn.adapter Faraday.default_adapter
    end
  end

  def self.fetch_gem(name)
    response = connection.get("gems/#{name}.json")
    return nil if response.status == 404

    JSON.parse(response.body)
  end

  def self.search_gems(query)
    response = connection.get('search.json', { query: query })
    return [] unless response.status == 200

    JSON.parse(response.body)
  end
end
