require 'rspec'
require_relative '../lib/card'

describe 'Card' do
  context 'initialize' do
    it("creates a card with a specified rank and suit") do
      test_card = Card.new(rank: "4", suit:"D")
      expect(test_card.rank).to(eq("4"))
      expect(test_card.suit).to(eq("D"))
      test_card_b = Card.new(rank: "7", suit:"S")
      expect(test_card_b.rank).to(eq("7"))
      expect(test_card_b.suit).to(eq("S"))
    end
  end

  context 'description' do
    it("returns a string describing this card") do
      test_card = Card.new(rank: "4", suit:"D")
      expect(test_card.description).to(eq("4 of Diamonds"))
      test_card_b = Card.new(rank: "Q", suit:"H")
      expect(test_card_b.description).to(eq("Queen of Hearts"))
    end
  end
end
