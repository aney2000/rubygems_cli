# frozen_string_literal: true

require_relative '../api'
require_relative '../cache'
require_relative '../gem_model'
require_relative '../printer'
require_relative 'search/options_parser'

module Commands
  class Search
    def initialize(args)
      @args = args
    end

    def execute
      args = @args
      query = args.shift
      if query.nil?
        Printer.error('Search keyword required.')
        exit(1)
      end

      options = OptionsParser.parse(args)

      raw_results = Cache.read(query)

      if raw_results.nil?
        raw_results = Api.search_gems(query)
        Cache.write(query, raw_results) unless raw_results.empty?
      end

      gems = GemModel.build_collection(raw_results)
      gems = gems.select { |gem| gem.licenses.include?(options[:license]) } if options[:license]
      gems = gems.sort_by { |gem| -gem.downloads } if options[:most_downloads]

      if gems.empty?
        Printer.info('No gems found matching the criteria.')
      else
        gems.each { |gem| Printer.gem_info('name' => gem.name, 'info' => gem.info) }
      end

      exit(0)
    end
  end
end
