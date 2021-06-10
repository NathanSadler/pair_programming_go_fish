require_relative '../lib/game'
require_relative '../lib/deck'
require_relative '../lib/player'
require_relative '../lib/go_fish_server'

describe 'Game' do
  let(:game) {Game.new}
  context '#initialize' do
    it('creates a game without any players') do
      expect(game.players.length).to(eq(0))
    end
    it("starts with a shuffled deck of cards") do
      expect(game.deck).to_not eq(Deck.new)
    end
    it("starts with books_made at 0") do
      expect(game.books_made).to(eq(0))
    end
  end

  context '#increase_total_score' do
    it('increases the books_made variable by a given amount') do
      game.increase_total_score(2)
      game.increase_total_score(1)
      expect(game.books_made).to(eq(3))
    end
  end

  context '#is_deck_empty?' do
    it('is true if the deck the game uses is empty') do
      52.times {game.deck.draw_card}
      expect(game.is_deck_empty?).to(eq(true))
    end
    it("is false if the deck isn't empty") do
      expect(game.is_deck_empty?).to(eq(false))
    end
  end

  context '#add_player' do
    it("adds a player to the game") do
      game.add_player(Player.new)
      expect(game.players.length).to(eq(1))
    end
  end

  context '#send_message_to_player' do
    let!(:test_server) {GoFishServer.new(3336)}
    let!(:test_socket) {TCPSocket.new('localhost', 3336)}
    after(:each) do
      test_socket.close
      test_server.stop
    end
    it("sends a message to a specified player") do
      test_server.accept_client
      player = test_server.create_player_from_client(test_server.clients[0])
      game.add_player(test_server.players[0])
      game.send_message_to_player(0, "Hello there, player 0")
      expect(test_socket.gets.include?("Hello there, player 0")).to(eq(true))
    end
  end

end
