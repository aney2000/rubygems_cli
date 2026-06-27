# frozen_string_literal: true

require_relative '../../lib/commands/search'

RSpec.describe Commands::Search do
  describe '#execute' do
    subject(:execute) { described_class.new(args).execute }

    context 'when no query is given' do
      let(:args) { [] }

      before { allow(Printer).to receive(:error) }

      it 'prints an error and exits with 1' do
        expect { execute }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        expect(Printer).to have_received(:error).with('Search keyword required.')
      end
    end

    # TODO: add specs for --license filter, --most-downloads-first sort, cache hit/miss, and empty results etc
    # already should have been done
  end
end
