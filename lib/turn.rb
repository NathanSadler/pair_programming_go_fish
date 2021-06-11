class Turn
  attr_accessor :player, :game
  def initialize(player, game)
    @player = player
    @game = game
  end

  def select_other_player
    game.send_message_to_player(game.players.index(player), "Enter a number " +
  "to select a player")
    list_other_players
    player_input = player.read_user_input
    returned_player = game.players[player_input.to_i]
    !returned_player.nil? ? returned_player : "not a valid input"
  end

  def list_other_players
    other_players = game.players.select {|other_player| other_player != player}
    counter, message = [1, ""]
    other_players.each  do |listable_player|
      message += "#{counter}: #{listable_player.name}" + "\n"
      counter += 1
    end
    player.send_message_to_user(message)
  end
end
