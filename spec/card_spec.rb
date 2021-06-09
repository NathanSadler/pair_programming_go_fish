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

  context '==' do
    let(:test_card) {Card.new(rank: "7", suit:"D")}
    it("is true if the rank and suit are both equal") do
      expect(test_card == Card.new(rank: "7", suit: "D")).to(eq(true))
    end
    it("is false if the ranks are different") do
      expect(test_card == Card.new(rank: "6", suit: "D")).to(eq(false))
    end
    it("is false if the suits are different") do
      expect(test_card == Card.new(rank: "7", suit: "C")).to(eq(false))
    end
  end
end
