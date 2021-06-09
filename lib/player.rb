class Player
  attr_accessor :hand, :score
  def initialize
    @hand = []
    @score = 0
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      hand.concat(card)
    else
      hand.push(card)
    end
  end

  def has_card_with_rank?(rank)
    (hand.select {|card| card.rank == rank}).length > 0
  end

  def remove_cards_with_rank(rank)
    cards_to_remove = hand.select {|card| card.rank == rank}
    self.hand -= cards_to_remove
    cards_to_remove
  end

  def find_book_ranks
    occurences = {}
    hand.each do |card|
      occurences[card.rank] ? occurences[card.rank] += 1 : occurences[card.rank] = 1
    end
    occurences.keys.select {|rank| occurences[rank] == 4}
  end

  def lay_down_books
    book_ranks = find_book_ranks
    books = hand.select {|card| book_ranks.include?(card.rank)}
    self.score += books.length / 4
    self.hand -= books
  end
end
