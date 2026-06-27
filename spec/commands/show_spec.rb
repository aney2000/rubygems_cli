# frozen_string_literal: true

require_relative '../../lib/commands/show'

RSpec.describe Commands::Show do
  describe '#execute' do
    subject(:execute) { described_class.new(gem_name).execute }

    context 'when no gem name is given' do
      let(:gem_name) { nil }

      before { allow(Printer).to receive(:error) }

      it 'prints an error and exits with 1' do
        expect { execute }.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        expect(Printer).to have_received(:error).with('Gem name required.')
      end
    end

    # TODO: add specs for the remaining cases
  end
end
