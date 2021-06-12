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
    it("works even works when the player the user selects comes before them in "+
    "the player order") do
      client_list[1].provide_input("1")
      turn = Turn.new(server.waiting_game.players[1], server.waiting_game)
      selected_player = turn.select_other_player
      expect(selected_player).to(eq(server.waiting_game.players[0]))
    end
    it("returns an error message if the user doesn't give a valid response") do
      client_list[0].provide_input("9999999999999999")
      turn = Turn.new(server.waiting_game.players[0], server.waiting_game)
      given_output = turn.select_other_player
      expect(given_output.include?("not a valid input")).to(eq(true))
    end
  end

  context('#add_and_reaveal') do
    before(:each) do
      2.times do
        test_client_list.push(GoFishClient.new(3337))
        test_server.accept_client
        test_server.try_to_add_player_to_game
      end
      test_server.waiting_game.players[0].set_user_name("Roger")
      test_server.waiting_game.players[1].set_user_name("Craig")
    end
    let(:cards) {[Card.new(rank:"8", suit:"D"), Card.new(rank:"8", suit:"S")]}
    let(:test_turn) {Turn.new(test_server.waiting_game.players[0], test_server.waiting_game)}
    it("adds specified cards to the player") do
      test_turn.add_and_reaveal(cards, test_server.waiting_game.players[1])
      expect(test_server.waiting_game.players[0].hand).to(eq(cards))
    end
    it("sends a message to all players about who got the cards and where the "+
    "cards came from") do
      announcement = "Roger took 8 of Diamonds from the deck"
      test_turn.add_and_reaveal(cards[0], "the deck")
      test_client_list.each do |client|
        expect(client.capture_output).to(eq(announcement))
      end
    end
    it("defaults to using 'the deck' as the source") do
      announcement = "Roger took 8 of Diamonds from the deck"
      test_turn.add_and_reaveal(cards[0])
      test_client_list.each do |client|
        expect(client.capture_output).to(eq(announcement))
      end
    end
    it("uses the given player's name as the source if the source is a Player "+
    "object") do
      test_turn.add_and_reaveal(cards, test_turn.game.players[1])
      expect(test_client_list[0].capture_output.include?("Roger took 8 of " +
        "Diamonds from Craig")).to(eq(true))
      expect(test_client_list[1].capture_output.include?("Roger took 8 of " +
        "Spades from Craig"))
    end
  end

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

  context('#try_getting_cards_from_player') do
    before(:each) do
      2.times do
        test_client_list.push(GoFishClient.new(3337))
        test_server.accept_client
        test_server.try_to_add_player_to_game
      end
      test_server.waiting_game.players[0].add_card_to_hand([Card.new(rank:"3", suit:"S"), Card.new(rank:"4", suit:"S")])
      test_server.waiting_game.players[1].add_card_to_hand([Card.new(rank:"3", suit:"D"), Card.new(rank:"3", suit:"H"), Card.new(rank:"5", suit:"D")])
    end
    let!(:player_1) {test_server.waiting_game.players[0]}
    let!(:player_2) {test_server.waiting_game.players[1]}
    let!(:test_turn) {Turn.new(player_1, test_server.waiting_game)}

    it("gives cards of a given rank from a player to another player asking for cards if "+
    "the first player has cards of the rank the second is asking for") do
      test_client_list[0].provide_input("3")
      selected_rank = player_1.select_rank
      test_client_list[0].provide_input("1")
      test_turn.try_getting_cards_from_player(selected_rank)
      expect(player_1.has_card?(Card.new(rank:"3", suit:"D"))).to(eq(true))
      expect(player_1.has_card?(Card.new(rank:"3", suit:"H"))).to(eq(true))
      expect(player_1.has_card?(Card.new(rank:"4", suit:"S"))).to(eq(true))
    end
    it("doesn't give cards that don't match the rank that got asked for") do
      test_client_list[0].provide_input("4")
      selected_rank = player_1.select_rank
      test_client_list[0].provide_input("1")
      test_turn.try_getting_cards_from_player(selected_rank)
      expect(player_1.hand.length).to(eq(2))
    end
    it("actually removes cards from the player being asked for cards if they "+
    "have cards of the specified rank") do
      test_client_list[0].provide_input("3")
      selected_rank = player_1.select_rank
      test_client_list[0].provide_input("1")
      test_turn.try_getting_cards_from_player(selected_rank)
      expect(player_2.hand).to(eq([Card.new(rank:"5", suit:"D")]))
    end
  end

  context('#list_other_players') do
    let(:game) {Game.new}
    let(:players) {players = ["A", "B", "C"].map {|name| Player.new(nil, name)}}
    before(:each) do
      players.each {|player| game.add_player(player)}
    end
    it("returns a list with every player in the game except for the player "+
    "associated with the turn object") do
      turn = Turn.new(players[1], game)
      expect(turn.list_other_players).to(eq([players[0], players[2]]))
    end
  end

  context('#display_other_players') do
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
      turn.display_other_players
      user_output = client_list[1].capture_output
      expect(user_output.include?("1: Huey")).to(eq(true))
      expect(user_output.include?("2: Lebron")).to(eq(true))
    end
  end
end
