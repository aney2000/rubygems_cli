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
      described_class.write('rails', [{ 'name' => 'rails' }])

      expect(File.exist?(File.join('cache_store', 'rails.json'))).to be(true)
    end
  end

  describe '.read' do
    it 'returns cached data when the file exists and is still fresh' do
      described_class.write('rails', [{ 'name' => 'rails' }])

      expect(described_class.read('rails')).to eq([{ 'name' => 'rails' }])
    end

    it 'returns nil when no cache file exists' do
      expect(described_class.read('missing')).to be_nil
    end

    it 'returns nil and deletes the cache file when it is older than two days' do
      described_class.write('rails', [{ 'name' => 'rails' }])
      file_path = described_class.path_for('rails')
      File.utime(Time.now - ((2 * 24 * 60 * 60) + 1), Time.now - ((2 * 24 * 60 * 60) + 1), file_path)

      expect(described_class.read('rails')).to be_nil
      expect(File.exist?(file_path)).to be(false)
    end

    it 'returns nil and warns when the cache file contains invalid JSON' do
      FileUtils.mkdir_p('cache_store')
      File.write(described_class.path_for('broken'), 'not-json')

      expect { expect(described_class.read('broken')).to be_nil }
        .to output(/Cache read error/).to_stderr
    end
  end

  describe '.write error handling' do
    it 'warns and does not raise when writing fails' do
      allow(File).to receive(:write).and_raise(StandardError, 'disk full')

      expect { described_class.write('rails', [{ 'name' => 'rails' }]) }
        .to output(/Cache write error/).to_stderr
    end
  end
end
