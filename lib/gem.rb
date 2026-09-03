# frozen_string_literal: true

module RubygemsCli
  class Gem
    attr_reader :name, :info, :downloads, :licenses

    def self.build_collection(array_of_hashes)
      array_of_hashes.map { |data| new(data) }
    end

    def initialize(data)
      @name = data['name']
      @info = data['info'] || ''
      @downloads = data['downloads'] || 0
      @licenses = data['licenses'] || []
    end

    def matches_name?(keyword)
      @name.downcase.include?(keyword.downcase)
    end

    def matches_keyword?(keyword)
      normalized = keyword.downcase
      @name.downcase.include?(normalized) || @info.downcase.include?(normalized)
    end
  end
end
