# frozen_string_literal: true

require_relative '../../../lib/commands/search/options_parser'

RSpec.describe Commands::Search::OptionsParser do
  describe '.parse' do
    subject(:parsed) { described_class.parse(args) }

    context 'with --most-downloads-first' do
      let(:args) { ['--most-downloads-first'] }

      it 'sets :most_downloads to true' do
        expect(parsed).to eq(most_downloads: true)
      end
    end

    # TODO: add specs for --license (consumes next arg), unknown flags ignored, and empty args etc
    # should have been done already
  end
end
