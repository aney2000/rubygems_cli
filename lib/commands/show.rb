# frozen_string_literal: true

require_relative '../api'
require_relative '../printer'

module Commands
  class Show
    def initialize(gem_name)
      @gem_name = gem_name
    end

    def execute
      if @gem_name.nil?
        Printer.error('Gem name required.')
        exit(1)
      end

      gem_data = Api.fetch_gem(@gem_name)

      if gem_data.nil?
        Printer.error("Gem '#{@gem_name}' not found.")
        exit(1)
      end

      Printer.gem_info(gem_data)
      exit(0)
    end
  end
end
