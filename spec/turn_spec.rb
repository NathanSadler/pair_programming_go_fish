require_relative '../lib/turn'
require_relative '../lib/go_fish_server'
require_relative '../lib/go_fish_client'
require 'pry'

describe 'Turn' do
  let!(:test_server) {GoFishServer.new(3337)}
  let!(:test_client_list) {[]}
  after(:each) do
    test_client_list.each {|client| client.close}
    test_server.stop
  end
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
        server.accept_client
        client_list.push(GoFishClient.new)
        server.try_to_add_player_to_game
        server.waiting_game.players[-1].set_user_name(name)
      end
    end
    after(:each) do
      client_list.each {|client| client.close}
      server.stop
    end
    it("returns the player corresponding to the number the user enters") do
      client_list[0].provide_input("1")
      turn = Turn.new(server.waiting_game.players[0], server.waiting_game)
      selected_player = turn.select_other_player
      expect(selected_player).to(eq(server.waiting_game.players[1]))
    end
    it("returns an error message if the user doesn't give a valid response") do
      client_list[0].provide_input("9999999999999999")
      turn = Turn.new(server.waiting_game.players[0], server.waiting_game)
      given_output = turn.select_other_player
      expect(given_output.include?("not a valid input")).to(eq(true))
    end
  end

  context('#list_other_players') do
    let!(:server) {GoFishServer.new}
    let(:game) {Game.new}
    let(:client_list) {[]}
    before(:each) do
      ["Huey", "Duey", "Lebron"].each do |name|
        server.accept_client
        client_list.push(GoFishClient.new)
        server.try_to_add_player_to_game
        server.waiting_game.players[-1].set_user_name(name)
      end
    end
    after(:each) do
      client_list.each {|client| client.close}
      server.stop
    end
    it("returns a list of all players except for the user seeing the list") do
      turn = Turn.new(server.waiting_game.players[1], server.waiting_game)
      turn.list_other_players
      user_output = client_list[1].capture_output
      expect(user_output.include?("1: Huey")).to(eq(true))
      expect(user_output.include?("2: Lebron")).to(eq(true))
    end
  end
end
