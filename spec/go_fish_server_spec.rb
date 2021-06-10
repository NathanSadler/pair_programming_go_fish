require_relative '../lib/go_fish_server'
require_relative '../lib/player'
require 'socket'

describe 'GoFishServer' do
  let(:server) {GoFishServer.new}

  after(:each) do
    server.stop
  end

  context('#accept_client') do
    it("accepts a client and creates a Player object from it") do
      server.accept_client
      expect(server.clients.empty?).to(eq(true))
      test_socket = TCPSocket.new('localhost', 3336)
      expect(server.clients.length).to(eq(0))
      expect(server.players.length).to(eq(0))
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


end
