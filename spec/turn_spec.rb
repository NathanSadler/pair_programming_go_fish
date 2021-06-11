require_relative '../lib/turn'
describe 'Turn' do
  context('#initialize') do
    it("creates a new Turn object using a Player") do
      test_player = Player.new
      test_turn = Turn.new(test_player)
      expect(test_turn.player).to(eq(test_player))
    end
  end
end
