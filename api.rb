require 'faraday'
require 'json'

def show_gem(name)
  url = "https://rubygems.org/api/v1/gems/#{name}.json"
  response = Faraday.get(url)

  if response.status == 404
    puts "Error: Gem '#{name}' not found."
    exit(1)
  end

  gem_data = JSON.parse(response.body)

  puts "=" * 60
  puts "GEM: #{gem_data['name'].upcase}"
  puts "=" * 60
  puts "Version: #{gem_data['version']}"
  puts "Info:    #{gem_data['info']}"
  puts "Link:    #{gem_data['project_uri']}"
  puts "=" * 60
end

def search_gems(keyword)
  url = "https://rubygems.org/api/v1/search.json?query=#{keyword}"
  response = Faraday.get(url)

  if response.status != 200
    puts "Error: Failed to search for gems."
    exit(1)
  end

  gems_list = JSON.parse(response.body)

  if gems_list.empty?
    puts "No gems found matching '#{keyword}'."
    return
  end

  sorted_gems = gems_list.sort_by do |gem_data|
    if gem_data['name'].downcase.include?(keyword.downcase)
      0 
    else
      1
    end
  end

  puts "\nSearch results for: '#{keyword.upcase}'"
  puts "-" * 100
  
  sorted_gems.each do |gem_data|
    name_col = gem_data['name'].ljust(30)
    version_col = "v#{gem_data['version']}".ljust(10)
    clean_info = gem_data['info'].to_s.gsub("\n", " ")[0..50]
    
    puts "#{name_col} | #{version_col} | #{clean_info}..."
  end
  puts "-" * 100
end