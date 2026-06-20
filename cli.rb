# frozen_string_literal: true

require_relative './lib/api'
require_relative './lib/printer'

class CLI
  def self.run(args)
    command = args.shift
    argument = args.shift

    if command.nil?
      Printer.print_error('No command provided.')
      exit(1)
    elsif command == 'show'
      handle_show_command(argument)
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
    else
      Printer.print_gem_info(gem_data)
      exit(0)
    end
  end
end

if __FILE__ == $0
  success = CLI.run(ARGV)
  exit(success ? 0 : 1)
end