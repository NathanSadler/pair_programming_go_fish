require 'deck'

class Game
  attr_reader :players
  attr_accessor :books_made, :deck

  def initialize
    @players = []
    @deck = Deck.new
    @deck.shuffle
    @books_made = 0
  end

  def play_game
    # Deal cards to all players
    # In a loop, let everyone take their turn(s)
  end

  def increase_total_score(new_book_count)
    self.books_made += new_book_count
  end

  def is_deck_empty?
    deck.empty?
  end

end
