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

  context('#create_player_from_client') do
    it("creates a Player using a specified client") do
      server_side_socket = TCPSocket.new('localhost', 3336)
      server.accept_client
      expect(server.players.length).to(eq(1))
      server_side_socket.close
    end
  end

end
