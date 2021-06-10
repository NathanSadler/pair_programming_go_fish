require_relative '../lib/player'
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

  context('#remove_cards_with_rank') do
    it('returns and removes all cards with a specified rank') do
      cards = [Card.new(rank: "8", suit: "S"), Card.new(rank: "8", suit:"D"),
        Card.new(rank: "4", suit: "H")]
      player.add_card_to_hand(cards)
      removed_cards = player.remove_cards_with_rank("8")
      expect(player.hand).to(eq([Card.new(rank: "4", suit: "H")]))
      expect(removed_cards).to(eq([Card.new(rank: "8", suit: "S"), Card.new(rank: "8", suit:"D")]))
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

  context('#get_user_input') do
    let!(:test_server) {TCPServer.new(3338)}
    after(:each) do
      test_server.close
    end
    it("gets input sent from a user and returns it") do
      test_socket = TCPSocket.new('localhost',3338)
      server_side_socket = test_server.accept_nonblock
      test_socket.puts("This is a test")
      test_player = Player.new(server_side_socket)
      expect(test_player.get_user_input).to(eq("This is a test"))
    rescue IO::WaitReadable
      expect(false).to be true
    end
  end
end
