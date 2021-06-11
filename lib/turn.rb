class Turn
  attr_accessor :player, :game
  def initialize(player, game)
    @player = player
    @game = game
  end

  def list_other_players
    other_players = game.players.select {|other_player| other_player != player}
    counter, message = [1, ""]
    other_players.each  do |listable_player|
      message += "#{counter}: #{listable_player.name}" + "\n"
      counter += 1
    end
    game.send_message_to_player(game.players.index(player), message)
  end
end
