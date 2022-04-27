# frozen_string_literal: true

require_relative '../lib/game'

# rubocop: disable Metrics/BlockLength

RSpec.describe Game do
  subject(:game) { described_class.new }
  let(:players) { game.instance_variable_get(:@players) }
  let(:grid) { game.instance_variable_get(:@grid) }

  describe '#start_players' do
    let(:player1) { Player.new('Claire', 'C', 1) }
    let(:player2) { Player.new('Teresa', 'T', 2) }
    let(:player3) { Player.new('Teresa', 'C', 2) }

    context 'when both players insert distinct tokens' do
      before do
        allow(game).to receive(:start_player).with(1).and_return(player1)
        allow(game).to receive(:start_player).with(2).and_return(player2)
      end

      it 'adds 2 players to @players' do
        initial_players = []
        added_players = [player1, player2]

        expect { game.start_players }.to change { players }
          .from(initial_players).to(added_players)
      end
    end

    context 'when both players insert same tokens' do
      before do
        allow(game).to receive(:start_player).with(1).and_return(player1)
        allow(game).to receive(:start_player).with(2).and_return(player3)
        allow(game).to receive(:distinct_tokens?).exactly(5).times.and_return(
          false, false, false, false, true
        )
        allow(game).to receive(:fetch_token).exactly(4).times
                                            .and_return('C', 'C', 'C', 'C', 'T')
      end

      it 'adds 2 players to @players' do
        initial_players = []
        added_players = [player1, player3]

        expect { game.start_players }.to change { players }
          .from(initial_players).to(added_players)
      end

      it 'loops until second player changes token' do
        expect(player3).to receive(:insert_token).exactly(4).times
        game.start_players
      end
    end
  end

  describe '#alternate_turns' do
    context 'while game does not end' do
      let(:turn_times) { 10 }

      before do
        response_array = Array.new(turn_times, false) << true
        allow(grid).to receive(:end?).exactly(turn_times + 1).times
                                     .and_return(*response_array)
      end

      it 'plays a turn' do
        expect(game).to receive(:play_turn).exactly(turn_times).times
        game.alternate_turns
      end

      it 'updates @turn' do
        expect { game.alternate_turns }
          .to change { game.instance_variable_get(:@turn) }
          .from(0).to(turn_times)
      end
    end
  end
end

# rubocop: enable Metrics/BlockLength
