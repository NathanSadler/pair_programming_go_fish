require_relative 'player'
require_relative 'game'
require 'socket'

class GoFishServer
  attr_accessor :waiting_game
  attr_reader :server, :players, :clients
  def initialize(port=3336)
    @server = TCPServer.new(port)
    @clients = []
    @players = []
    @waiting_game = Game.new
  end

  def accept_client
    client = server.accept_nonblock
    self.clients.push(client)
    self.players.push(Player.new(client, "Player Name"))
    #binding.pry
  rescue IO::WaitReadable
    retry
  end

  def create_game_if_needed
    if waiting_game.nil?
      self.waiting_game = Game.new
      return waiting_game
    end
    nil
  end

  def create_player_from_client(client)

    players.push(Player.new(client))
  end

  def stop
    server.close
  end
end
