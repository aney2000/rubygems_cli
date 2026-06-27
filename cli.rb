# frozen_string_literal: true

require_relative './lib/printer'
require_relative './lib/commands/show'
require_relative './lib/commands/search'

class CLI
  def self.run(args)
    command = args.shift

    case command
    when 'show'
      Commands::Show.new(args.shift).execute
    when 'search'
      Commands::Search.new(args).execute
    when nil
      Printer.error('No command provided.')
      exit(1)
    else
      Printer.error("Unknown command '#{command}'.")
      exit(1)
    end
  end
end

CLI.run(ARGV) if __FILE__ == $PROGRAM_NAME
