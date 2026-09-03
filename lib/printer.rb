# frozen_string_literal: true

class Printer
  def self.gem_info(gem_data)
    puts "GEM: #{gem_data['name']}"
    puts "Info: #{gem_data['info']}"
    puts '-' * 120
  end

  def self.print_error(message)
    puts "Error: #{message}"
    puts '-' * 120
  end
end
