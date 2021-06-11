require_relative '../lib/turn'
require_relative '../lib/go_fish_server'
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
  context('#select_other_player') do
    let!(:server) {GoFishServer.new}
    let(:game) {Game.new}
    let(:client_list) {[]}
    before(:each) do
      ["Huey", "Duey", "Lebron"].each do |name|
        
      end
    end
    after(:each) do
      client_list.each {|client| client.close}
      server.stop
    end
    it("returns the player corresponding to the number the user enters") do

    end
    it("doesn't list the user being prompted") do

    end
    it("retries if the user doesn't give a valid response") do

    end
  end
end
