# frozen_string_literal: true

class SearchOptions
  Result = Struct.new(:query, :most_downloads_first, :license, :error, keyword_init: true)

  def self.parse(args)
    query = args.shift
    return Result.new(error: 'Search keyword required.') if query.nil?

    most_downloads_first = false
    license = nil

    until args.empty?
      arg = args.shift

      case arg
      when '--most-downloads-first', '--recent-first'
        most_downloads_first = true
      when '--license', '--licence'
        license = args.shift
        return Result.new(error: 'Missing value for --license.') if license.nil? || license.empty?
      else
        return Result.new(error: "Unknown option '#{arg}'.")
      end
    end

    Result.new(query: query, most_downloads_first: most_downloads_first, license: license)
  end
end
