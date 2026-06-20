# frozen_string_literal: true

require 'faraday'
require 'json'

class Api
  def self.fetch_gem(name)
    url = "https://rubygems.org/api/v1/gems/#{name}.json"
    response = Faraday.get(url)

    return nil if response.status == 404

    JSON.parse(response.body)
  end
end