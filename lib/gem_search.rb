# frozen_string_literal: true

class GemSearch
  def initialize(gems, query:, license: nil, most_downloads_first: false)
    @gems = gems
    @query = query
    @license = license
    @most_downloads_first = most_downloads_first
  end

  def results
    filtered = @gems.select { |gem| gem.matches_keyword?(@query) }
    filtered = filtered.select { |gem| gem.licenses.include?(@license) } unless @license.nil?

    sort_results(filtered)
  end

  private

  def sort_results(gems)
    if @most_downloads_first
      gems.sort_by { |gem| [gem.matches_name?(@query) ? 0 : 1, -gem.downloads] }
    else
      gems.sort_by { |gem| gem.matches_name?(@query) ? 0 : 1 }
    end
  end
end
