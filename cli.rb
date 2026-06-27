# frozen_string_literal: true

require_relative './lib/api'
require_relative './lib/printer'
require_relative './lib/gem_model'
require_relative './lib/cache'

class CLI
  def self.run(args)
    command = args.shift

    case command
    when 'show'
      handle_show_command(args.shift)
    when 'search'
      handle_search_command(args)
    when nil
      Printer.print_error('No command provided.')
      exit(1)
    else
      Printer.print_error("Unknown command '#{command}'.")
      exit(1)
    end
  end

  def self.handle_show_command(gem_name)
    if gem_name.nil?
      Printer.print_error('Gem name required.')
      exit(1)
    end

    gem_data = Api.fetch_gem(gem_name)

    if gem_data.nil?
      Printer.print_error("Gem '#{gem_name}' not found.")
      exit(1)
    end

    Printer.gem_info(gem_data)
    exit(0)
  end

  def self.handle_search_command(args)
    query = args.shift
    if query.nil?
      Printer.print_error('Search keyword required.')
      exit(1)
    end

    options = {}
    while (arg = args.shift)
      if arg == '--most-downloads-first'
        options[:most_downloads] = true
      elsif arg == '--license'
        options[:license] = args.shift
      end
    end

    raw_results = Cache.read(query)

    if raw_results.nil?
      raw_results = Api.search_gems(query)
      Cache.write(query, raw_results) unless raw_results.empty?
    end

    gems = GemModel.build_collection(raw_results)

    gems = gems.sort_by { |gem| gem.matches_name?(query) ? 0 : 1 }

    gems = gems.select { |gem| gem.licenses.include?(options[:license]) } if options[:license]

    if options[:most_downloads]
      gems = gems.sort_by { |gem| [gem.matches_name?(query) ? 0 : 1, -gem.downloads] }
    end

    if gems.empty?
      puts 'No gems found matching the criteria.'
    else
      gems.each { |gem| Printer.gem_info('name' => gem.name, 'info' => gem.info) }
    end

    exit(0)
  end
end

CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
