# frozen_string_literal: true

require 'json'
require 'fileutils'

class Cache
  CACHE_DIR = 'cache_store'
  TWO_DAYS_IN_SECONDS = 2 * 24 * 60 * 60

  def self.read(query)
    file_path = path_for(query)
    return nil unless File.exist?(file_path)

    if (Time.now - File.mtime(file_path)) > TWO_DAYS_IN_SECONDS
      File.delete(file_path)
      return nil
    end

    JSON.parse(File.read(file_path))
  rescue StandardError => e
    # Gracefully handle corrupted cache files or permission issues
    # Log and return nil to fallback to API
    warn("Cache read error for #{query}: #{e.message}")
    nil
  end

  def self.write(query, data)
    FileUtils.mkdir_p(CACHE_DIR)
    File.write(path_for(query), JSON.generate(data))
  rescue StandardError => e
    # Gracefully handle permission issues or full disk scenarios
    # Proceed without cache rather than crashing the application
    warn("Cache write error for #{query}: #{e.message}")
  end

  def self.path_for(query)
    safe_query = query.gsub(/[^0-9A-Za-z.-]/, '_')
    File.join(CACHE_DIR, "#{safe_query}.json")
  end
end
