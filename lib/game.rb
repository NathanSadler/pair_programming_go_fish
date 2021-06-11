require_relative 'deck'

class Game
  attr_reader :players
  attr_accessor :books_made, :deck

  def initialize
    @players = []
    @deck = Deck.new
    @deck.shuffle
    @books_made = 0
  end

  # Returns the index of a given player in the players array
  def get_player_index(player)
    players.index(player)
  end

  def play_game
    (0...players.length).each {|index| send_message_to_player(index, "Dealing Cards...")}
    # Deal cards to all players
    deal_cards
    # In a loop, let everyone take their turn(s)
  end

  def increase_total_score(new_book_count)
    self.books_made += new_book_count
  end

  def is_deck_empty?
    deck.empty?
  end

  def add_player(player_to_add)
    players.push(player_to_add)
  end

  def send_message_to_player(player_index, message)
    players[player_index].socket.puts(message)
  end

  def deal_cards
    players.length > 3 ? (card_deal_count = 5) : (card_deal_count = 7)
    card_deal_count.times do
      players.each {|player| player.add_card_to_hand(deck.draw_card)}
    end
  end

end
