# frozen_string_literal: true

require_relative '../lib/printer'

RSpec.describe Printer do
  describe '.print_gem_info' do
    it 'formats and outputs gem information correctly to stdout' do
      fake_gem_data = { 'name' => 'test_gem', 'info' => 'A nice gem description.' }

      expect { Printer.print_gem_info(fake_gem_data) }
        .to output("GEM: test_gem\nInfo: A nice gem description.\n").to_stdout
    end
  end

  describe '.print_error' do
    it 'formats and outputs error messages correctly to stdout' do
      expect { Printer.print_error('Something went wrong') }
        .to output("Error: Something went wrong\n").to_stdout
    end
  end
end