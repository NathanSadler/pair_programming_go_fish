require_relative '../lib/go_fish_server'
require_relative '../lib/player'
require_relative '../lib/deck'
require 'socket'

describe 'GoFishServer' do
  let!(:server) {GoFishServer.new}

  after(:each) do
    server.stop
  end

  context('#accept_client') do
    it("accepts a client and creates a Player object from it") do
      expect(server.clients.empty?).to(eq(true))
      test_socket = TCPSocket.new('localhost', 3336)
      server.accept_client
      expect(server.clients.length).to(eq(1))
      expect(server.players.length).to(eq(1))
      test_socket.close
    end
  end

  context('#create_game_if_needed') do
    it("creates a new game if there isn't one available") do
      server.waiting_game = nil
      server.create_game_if_needed
      expect(server.waiting_game.nil?).to(eq(false))
    end
    it("returns the game it creates") do
      server.waiting_game = nil
      created_game = server.create_game_if_needed
      expect(server.waiting_game).to(eq(created_game))
    end
    it("doesn't create a game if there is an available one") do
      should_be_nil = server.create_game_if_needed
      expect(should_be_nil.nil?).to(eq(true))
    end
  end

  context('#try_to_add_player_to_game') do
    let!(:test_socket) {TCPSocket.new('localhost', 3336)}
    after(:each) do
      test_socket.close
    end
    it("adds a player to the waiting_game, if there are any players to add") do
      server.accept_client
      server.try_to_add_player_to_game
      expect(server.waiting_game.players.length).to(eq(1))
      test_socket.close
    end
    it("only adds one player to a game at a time") do
      server.accept_client
      second_test_socket = TCPSocket.new('localhost', 3336)
      server.accept_client
      server.try_to_add_player_to_game
      # This should be 1 because calling this should remove the player from the
      # server's players array since it gets added to the game.
      expect(server.players.length).to(eq(1))
      second_test_socket.close
    end
  end

  context('#start_waiting_game') do
    it("moves the ready game out of waiting_game and replaces it with a new game") do
      ready_game = server.waiting_game
      server.start_waiting_game
      expect(ready_game == server.waiting_game).to(eq(false))
    end
  end

end
