require 'optparse'
require_relative 'api'

parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby cli.rb [command] [arguments]"
  opts.separator ""
  opts.separator "Commands:"
  opts.separator "  search <keyword>   Search for gems by name or info"
  opts.separator "  show <gem_name>    Show details of a specific gem"
  opts.separator ""
  opts.separator "Options:"
  
  opts.on("-h", "--help", "Prints this help menu") do
    puts opts
    exit(0)
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  puts "Error: #{e.message}"
  puts parser
  exit(1)
end

command = ARGV.shift 
argument = ARGV.shift

if command.nil?
  puts "Error: No command provided.\n\n"
  puts parser
  exit(1)
end

case command
when 'search'
  if argument.nil?
    puts "Error: Keyword required. Usage: ruby cli.rb search <keyword>"
    exit(1)
  end
  search_gems(argument)
  exit(0)

when 'show'
  if argument.nil?
    puts "Error: Gem name required. Usage: ruby cli.rb show <gem_name>"
    exit(1)
  end
  show_gem(argument)
  exit(0)

else
  puts "Error: Unknown command '#{command}'.\n\n"
  puts parser
  exit(1)
end