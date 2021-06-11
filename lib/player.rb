class Player
  attr_reader :socket, :name, :in_game
  attr_accessor :hand, :score
  def initialize(socket=nil, name="Player Name")
    @hand = []
    @score = 0
    @socket = socket
    @name = name
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

  def read_user_input
    socket.gets.chomp
  end

  def send_message_to_user(message)
    socket.puts(message)
  end

  def lay_down_books
    book_ranks = find_book_ranks
    books = hand.select {|card| book_ranks.include?(card.rank)}
    self.score += books.length / 4
    self.hand -= books
  end

  def set_user_name(new_name)
    @name = new_name
  end
end
