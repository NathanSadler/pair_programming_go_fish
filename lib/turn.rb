class Turn
  attr_accessor :player, :game
  def initialize(player, game)
    @player = player
    @game = game
  end

  # Asks the user to select a player to get a card from and a rank to ask for
  # calls draw_from_deck if the player doesn't get the card and calls
  # take_and_reveal if it does
  def try_getting_cards_from_player
    selected_player, selected_rank = [select_other_player, player.select_rank]
    selected_player_id = game.players.index(selected_player)
    if game.players[selected_player_id].has_card_with_rank?(rank)
      ## TODO: write take_and_reaveal
      take_and_reveal(game.players[selected_player_id].remove_cards_with_rank, selected_player.name)
    else

    end
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

  def draw_from_deck(expected_rank = "B")
    if !game.deck.empty?
      drawn_card = game.deck.draw_card
      player.add_card_to_hand(drawn_card)
      return drawn_card.rank == expected_rank
    end
  end

  # TODO: Crunch this down into 7 or fewer lines. I'm not gonna be able to
  # get anywhere with this if I don't (temporarily) ignore this constraint
  def take_turn
    #
  end
end
