# frozen_string_literal: true

class Printer
  def self.print_gem_info(gem_data)
    puts "GEM: #{gem_data['name']}"
    puts "Info: #{gem_data['info']}"
  end

  def self.print_error(message)
    puts "Error: #{message}"
  end
end