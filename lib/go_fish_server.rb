require_relative 'player'
require 'socket'

class GoFishServer
  attr_reader :server, :players, :clients
  def initialize(port=3336)
    @server = TCPServer.new(port)
    @clients = []
    @players = []
  end

  # TODO: add create player part
  def accept_client
    client = server.accept_nonblock
    clients.push(client)
    players.push(Player.new(client, "Player Name"))
  rescue IO::WaitReadable
    ""
  end

  def create_player_from_client(client)
    players.push(Player.new(client))
  end

  def stop
    server.close
  end
end
