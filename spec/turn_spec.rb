require_relative '../lib/turn'
describe 'Turn' do
  context('#initialize') do
    it("creates a new Turn object using a Player and Game") do
      test_player = Player.new
      test_game = Game.new
      test_turn = Turn.new(test_player, test_game)
      expect(test_turn.player).to(eq(test_player))
      expect(test_turn.game).to(eq(test_game))
    end
  end
end
