require_relative 'player'
require_relative 'game'
require_relative 'deck'
require 'socket'

class GoFishServer
  attr_accessor :waiting_game, :games
  attr_reader :server, :players, :clients
  def initialize(port=3336)
    @server = TCPServer.new(port)
    @clients = []
    @games = []
    @players = []
    @waiting_game = Game.new
  end

  def accept_client
    client = server.accept_nonblock
    self.clients.push(client)
    create_player_from_client(client)
  rescue IO::WaitReadable
    ""
  end

  def create_game_if_needed
    if waiting_game.nil?
      self.waiting_game = Game.new
      return waiting_game
    end
    nil
  end

  def create_player_from_client(client, name="Player Name")
    self.players.push(Player.new(client, name))
  end

  def try_to_add_player_to_game
    accept_client
    if !players.empty?
      self.waiting_game.add_player(self.players.shift)
    end
  end

  # TODO: make it so that a new waiting_game can be created while other
  # games are being played
  def start_waiting_game
    # ready_game = waiting_game
    #
    # ready_game.play_game
    # self.waiting_game = Game.new
    games.push(waiting_game)
    self.waiting_game = Game.new
    print("1")
    thread = Thread.new {games[-1].play_game}
    print("2")
    thread.join
    print("3")
  end

  def stop
    server.close
  end
end
