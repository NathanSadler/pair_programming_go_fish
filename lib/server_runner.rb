require_relative 'go_fish_server'
require_relative 'deck'


# TODO: enable multiple games at once

main_server = GoFishServer.new

# Waiting for the game to start. See the 'wait_to_start_game flowchart' to be
# able to understand
while true
  ready_to_start = false
  waiting_players_since_last_check = 1

  while !ready_to_start
    # If there are only 0 or 1 people in the waiting_game, keep trying to add
    # new players to it.
    players_in_waiting_game = main_server.waiting_game.players.length
    if players_in_waiting_game <= 1
      main_server.try_to_add_player_to_game
    # If there are at least 2 players but less than 7 in the waiting_game,
    # keep trying to add players to it, but ask the first player if they are
    # ready to begin the game every time a player joins the game
    elsif players_in_waiting_game < 7
      if waiting_players_since_last_check < players_in_waiting_game
        waiting_players_since_last_check = players_in_waiting_game
        main_server.waiting_game.send_message_to_player(0, "A new player" +
        " has joined. Are you ready to begin the game?")
        ready_to_start = (main_server.waiting_game.players[0].read_user_input.chomp == "yes")
        print("OK")
      else
        main_server.try_to_add_player_to_game
      end
    # Automatically start the game if there are 7 people in the waiting_game
    else
      ready_to_start = true
    end
  end
  main_server.move_waiting_game
  main_server.start_last_ready_game
end
