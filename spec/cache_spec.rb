# frozen_string_literal: true

require 'tmpdir'
require_relative '../lib/cache'

RSpec.describe Cache do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe '.write' do
    it 'writes data to a cache file for the given query' do
      Cache.write('rails', [{ 'name' => 'rails' }])

      expect(File.exist?(File.join('cache_store', 'rails.json'))).to be(true)
    end
  end

  describe '.read' do
    it 'returns cached data when the file exists and is still fresh' do
      Cache.write('rails', [{ 'name' => 'rails' }])

      expect(Cache.read('rails')).to eq([{ 'name' => 'rails' }])
    end

    it 'returns nil when no cache file exists' do
      expect(Cache.read('missing')).to be_nil
    end

    it 'returns nil and deletes the cache file when it is older than two days' do
      Cache.write('rails', [{ 'name' => 'rails' }])
      file_path = Cache.path_for('rails')
      File.utime(Time.now - (2 * 24 * 60 * 60 + 1), Time.now - (2 * 24 * 60 * 60 + 1), file_path)

      expect(Cache.read('rails')).to be_nil
      expect(File.exist?(file_path)).to be(false)
    end
  end
end
