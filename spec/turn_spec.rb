require_relative '../lib/turn'
require_relative '../lib/go_fish_server'
require_relative '../lib/go_fish_client'
require_relative '../lib/deck'
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

  # context('#announce_obtaining_cards') do
  #   before(:each) do
  #     2.times do
  #       test_server.accept_client
  #       test_client_list.push(GoFishClient.new(3337, 'localhost'))
  #       test_server.try_to_add_player_to_game
  #     end
  #   end
  #   it("sends a message to a player obtaining a card containing what card they" +
  #   " got and where they got it from") do
  #     test_game = test_server.waiting_game
  #     turn = Turn.new(test_game.players[0], test_game)
  #     turn.announce_obtaining_cards(Card.new(rank:"7", suit:"D"), "the deck")
  #     expect(test_client_list[0].capture_output).to(eq("Player Name got a 7 of Diamonds from the deck"))
  #   end
  # end

  context('#draw_from_deck') do
    before(:each) do
      2.times do
        test_server.accept_client
        test_client_list.push(GoFishClient.new(3337, 'localhost'))
        test_server.try_to_add_player_to_game
      end
    end
    it("adds the card it draws to the player's hand") do
      test_game = Game.new
      test_player = Player.new
      test_game.add_player(test_player)
      test_game.deck = Deck.new([Card.new(rank:"7", suit:"H")])
      turn = Turn.new(test_player, test_game)
      turn.draw_from_deck
      expect(test_player.hand).to(eq([Card.new(rank:"7", suit:"H")]))
    end
    it("is true if the rank of the card that got drawn was the same as what the"+
    " user had asked for") do
      test_game = Game.new
      test_player = Player.new
      test_game.add_player(test_player)
      test_game.deck = Deck.new([Card.new(rank:"7", suit:"H")])
      turn = Turn.new(test_player, test_game)
      expect(turn.draw_from_deck("7")).to(eq(true))
    end
    it("is false if the rank of the card that got drawn was not the same as "+
    "what the user had asked for") do
      test_game = Game.new
      test_player = Player.new
      test_game.add_player(test_player)
      test_game.deck = Deck.new([Card.new(rank:"7", suit:"H")])
      turn = Turn.new(test_player, test_game)
      expect(turn.draw_from_deck("200")).to(eq(false))
    end
    it("doesn't do anything if there aren't any cards to draw") do
      test_game = Game.new
      2.times {test_game.add_player(Player.new)}
      test_game.deck = Deck.new([])
      turn = Turn.new(test_game.players[0], test_game)
      turn.draw_from_deck
      expect(test_game.players[0].hand).to(eq([]))
      expect(test_game.players[1].hand).to(eq([]))
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
