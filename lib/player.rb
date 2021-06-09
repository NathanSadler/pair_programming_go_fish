class Player
  attr_reader :hand
  def initialize
    @hand = []
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      hand.concat(card)
    else
      hand.push(card)
    end
  end

  def has_card_with_rank(rank)
  end
end
