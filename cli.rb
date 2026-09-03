# frozen_string_literal: true

require_relative 'lib/api'
require_relative 'lib/printer'
require_relative 'lib/gem'
require_relative 'lib/cache'
require_relative 'lib/search_options'
require_relative 'lib/search_gems_service'
require_relative 'lib/show_gem_service'
require_relative 'lib/gem_search'

class CLI
  def self.run(args)
    command = args.shift

    case command
    when 'show'
      safely_run { handle_show_command(args.shift) }
    when 'search'
      safely_run { handle_search_command(args) }
    when nil
      Printer.print_error('No command provided.')
      exit(1)
    else
      Printer.print_error("Unknown command '#{command}'.")
      exit(1)
    end
  end

  def self.safely_run
    yield
  rescue StandardError => e
    Printer.print_error("Unexpected error: #{e.message}")
    exit(1)
  end

  def self.handle_show_command(gem_name)
    if gem_name.nil?
      Printer.print_error('Gem name required.')
      exit(1)
    end

    gem_data = ShowGemService.new(api: Api, cache: Cache).call(gem_name)

    if gem_data.nil?
      Printer.print_error("Gem '#{gem_name}' not found.")
      exit(1)
    end

    Printer.gem_info(gem_data)
    exit(0)
  end

  def self.handle_search_command(args)
    parsed_options = SearchOptions.parse(args)

    unless parsed_options.error.nil?
      Printer.print_error(parsed_options.error)
      exit(1)
    end

    raw_results = SearchGemsService.new(api: Api, cache: Cache).call(parsed_options.query)
    gems = RubygemsCli::Gem.build_collection(raw_results)

    gems = GemSearch.new(
      gems,
      query: parsed_options.query,
      license: parsed_options.license,
      most_downloads_first: parsed_options.most_downloads_first
    ).results

    if gems.empty?
      puts 'No gems found matching the criteria.'
    else
      gems.each { |gem| Printer.gem_info('name' => gem.name, 'info' => gem.info) }
    end

    exit(0)
  end
end

CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
