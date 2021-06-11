require_relative 'GoFishServer'
# TODO: enable multiple games at once

main_server = GoFishServer.new

# Waiting for the game to start
ready_to_start = false
waiting_players_since_last_check = 1
while !ready_to_start
  players_in_waiting_game = main_server.waiting_game.players.length
  if players_in_waiting_game <= 1
    main_server.try_to_add_player_to_game
  elsif players_in_waiting_game < 7
    if waiting_players_since_last_check < players_in_waiting_game
      waiting_players_since_last_check = players_in_waiting_game
      main_server.waiting_game.send_message_to_player(0, "A new player" +
      " has joined. Are you ready to begin the game?")
      
    end
  end
end
