# frozen_string_literal: true

module Commands
  class Search
    class OptionsParser
      def self.parse(args)
        options = {}
        while (arg = args.shift)
          if arg == '--most-downloads-first'
            options[:most_downloads] = true
          elsif arg == '--license'
            options[:license] = args.shift
          end
        end
        options
      end
    end
  end
end
