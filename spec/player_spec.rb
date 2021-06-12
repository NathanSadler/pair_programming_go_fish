require_relative '../lib/player'
require_relative '../lib/card'
require_relative '../lib/go_fish_server'

require 'socket'
require 'pry'
describe 'Player' do
  let(:player) {Player.new}
  context('#initialize') do
    it("doesn't have any cards when created") do
      expect(player.hand).to(eq([]))
    end
  end

  context('#add_card_to_hand') do
    it("adds a card to the player's hand") do
      test_card = Card.new(rank:"7", suit:"H")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([test_card]))
    end
    it("can add multiple cards to the player's hand") do
      test_cards = [Card.new(rank:"9", suit:"C"), Card.new(rank:"K", suit:"S")]
      player.add_card_to_hand(test_cards)
      expect(player.hand).to(eq(test_cards))
    end
    it("does not just replace the player's hand") do
      player.add_card_to_hand(Card.new(rank:"9", suit:"D"))
      test_card = Card.new(rank:"J", suit:"C")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([Card.new(rank: "9", suit: "D"), test_card]))
    end
  end

  context('#select_rank') do
    let!(:test_server) {GoFishServer.new(3337)}
    let!(:test_client_list) {[]}
    before(:each) do
      test_client_list.push(GoFishClient.new(3337))
      test_server.accept_client
      test_server.try_to_add_player_to_game
    end
    after(:each) do
      test_client_list.each {|client| client.close}
      test_server.stop
    end
    it("gets a rank from the player to ask for") do
      test_server.waiting_game.players[0].add_card_to_hand(Card.new(rank:"7", suit:"H"))
      test_client_list[0].provide_input("7")
      selected_rank = test_server.waiting_game.players[0].select_rank
      expect(selected_rank).to(eq("7"))
    end
    it("returns an error message if the user inputs a rank they don't have") do
      test_server.waiting_game.players[0].add_card_to_hand(Card.new(rank:"7", suit:"H"))
      test_client_list[0].provide_input("Q")
      output = test_server.waiting_game.players[0].select_rank
      expect(output).to(eq("not a valid input"))
    end
  end

  context('#has_card_with_rank?') do
    before(:each) do
      player.add_card_to_hand(Card.new(rank: "7", suit: "K"))
    end
    it("is true if the player has a card with the specified rank") do
      expect(player.has_card_with_rank?("7")).to(eq(true))
    end
    it("is false if the player doesn't have a card with the specified rank") do
      expect(player.has_card_with_rank?("8")).to(eq(false))
    end
  end

  context('#get_player_index') do
    it('returns the index of a given player in the players array') do
      test_game = Game.new
      test_players = [Player.new(nil, 'Player 1'), Player.new(nil, 'Player 2')]
      test_players.each {|test_player| test_game.add_player(test_player)}
      expect(test_game.get_player_index(test_players[0])).to(eq(0))
      expect(test_game.get_player_index(test_players[1])).to(eq(1))
    end
  end

  context('#remove_cards_with_rank') do
    it('returns and removes all cards with a specified rank') do
      cards = [Card.new(rank: "8", suit: "S"), Card.new(rank: "8", suit:"D"),
        Card.new(rank: "4", suit: "H")]
      player.add_card_to_hand(cards)
      removed_cards = player.remove_cards_with_rank("8")
      expect(player.hand).to(eq([Card.new(rank: "4", suit: "H")]))
      expect(removed_cards).to(eq([Card.new(rank: "8", suit: "S"), Card.new(rank: "8", suit:"D")]))
    end
    it('returns an empty array if the player does not have cards of the '+
    'specified ranks') do
      cards = [Card.new(rank:"7", suit:"H"), Card.new(rank:"9", suit:"S")]
      removed_cards = player.remove_cards_with_rank("2")
      expect(removed_cards).to(eq([]))
    end
  end

  context('#find_book_ranks') do
    it("returns an array the ranks of each book") do
      book = ["S", "D", "H", "C"].map {|suit| Card.new(rank: "7", suit: suit)}
      player.add_card_to_hand(book)
      player.add_card_to_hand(Card.new(rank: "4", suit: "S"))
      expect(player.find_book_ranks).to(eq(["7"]))
    end
  end

  context('#lay_down_books') do
    it("removes a book from the hand and increases the player's score") do
      book = ["S", "D", "H", "C"].map {|suit| Card.new(rank: "7", suit: suit)}
      player.add_card_to_hand(book)
      player.add_card_to_hand(Card.new(rank: "4", suit: "S"))
      player.lay_down_books
      expect(player.hand).to(eq([Card.new(rank: "4", suit: "S")]))
      expect(player.score).to(eq(1))
    end
  end

  context('#read_user_input') do
    let!(:test_server) {TCPServer.new(3338)}
    after(:each) do
      test_server.close
    end
    it("gets input sent from a user and returns it") do
      test_socket = TCPSocket.new('localhost',3338)
      server_side_socket = test_server.accept_nonblock
      test_socket.puts("This is a test")
      test_player = Player.new(server_side_socket)
      expect(test_player.read_user_input).to(eq("This is a test"))
    rescue IO::WaitReadable
      expect(false).to be true
    end
  end

  context('#send_message_to_user') do
    let!(:test_server) {GoFishServer.new}
    let!(:test_client) {GoFishClient.new}
    after(:each) do
      test_client.close
      test_server.stop
    end

    it("sends a message to the user") do
      test_server.accept_client
      test_message = "This is being sent from the player class"
      test_server.players[0].send_message_to_user(test_message)
      expect(test_client.capture_output.include?(test_message)).to(eq(true))
    end
  end

  context('#set_user_name') do
    it("updates the name of the player") do
      test_player = Player.new
      test_player.set_user_name("FooBar")
      expect(test_player.name).to(eq("FooBar"))
    end
  end

  context('#describe_cards') do
    it("returns a string containing a description of every card the player has") do
      player.add_card_to_hand([Card.new(rank: "4", suit: "D"),
        Card.new(rank:"5", suit:"S")])
      description = player.describe_cards
      expect(description.include?("4 of Diamonds")).to(eq(true))
      expect(description.include?("5 of Spades")).to(eq(true))
      expect(description.include?("10 of Hearts")).to(eq(false))
    end
  end

  context('#has_card?') do
    before(:each) {player.add_card_to_hand(Card.new(rank:"4", suit:"S"))}
    it("is true if the player has the specified card in their hand") do
      expect(player.has_card?(Card.new(rank:"4", suit:"S"))).to(eq(true))
    end
    it("is false if the player doesn't have the specified card in their hand") do
      expect(player.has_card?(Card.new(rank:"5", suit:"S"))).to(eq(false))
    end
  end

end
