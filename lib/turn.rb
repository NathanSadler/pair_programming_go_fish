class Turn
  attr_accessor :player, :game
  def initialize(player, game)
    @player = player
    @game = game
  end

  # Asks the user to select a player to get a card from and a rank to ask for
  # calls add_and_reaveal and returns true if the player gets the card and calls
  def try_getting_cards_from_player(selected_rank)
    selected_player = select_other_player
    selected_player_id = game.get_player_index(player)
    #binding.pry
    if game.players[selected_player_id].has_card_with_rank?(selected_rank)
      add_and_reaveal(game.players[selected_player_id].remove_cards_with_rank(selected_rank), selected_player.name)
      return true
    end
    return false
  end

  # Lets the user ask for cards unitl they don't get a card with the rank
  # they ask for
  def ask_for_cards_until_go_fish
    selected_rank = player.select_rank
    turn_over = false
    until turn_over
      if !try_getting_cards_from_player
        turn_over = false
      end
    end
  end

  # Adds cards to a player's hand and then Sends a message to all of the game's
  # players revealing what cards the player took and where they got it from.
  ## TODO: make it so that the cards the player already has don't get mentioned
  def add_and_reaveal(cards, source="the deck")
    #print("AAAAA#{cards}AAAAA")
    player.add_card_to_hand(cards)
    message = ""
    if source.is_a?(Player) then display_source = source.name else display_source = source end
    if cards.is_a?(Array) then cards.each {|card| message += "#{player.name} took #{card.description} from #{display_source}\n"} end
    if !cards.is_a?(Array) then message = "#{player.name} took #{cards.description} from #{display_source}\n" end
    game.players.each {|player| player.send_message_to_user(message)}
  end

  def select_other_player
    game.send_message_to_player(game.players.index(player), "Enter a number " +
  "to select a player")
    display_other_players
    player_input = player.read_user_input
    returned_player = game.players[player_input.to_i]
    !returned_player.nil? ? returned_player : "not a valid input"
  end

  def list_other_players
    game.players.select {|other_player| other_player != player}
  end

  def display_other_players
    other_players = list_other_players
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
    try_getting_cards_from_player
    player.lay_down_books
  end
end
