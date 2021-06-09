require_relative '../lib/deck'
describe 'Deck' do
  let(:test_deck) {Deck.new}
  context('.initialize') do
    it("creates a deck of 52 cards") do
      expect(test_deck.cards.length).to(eq(52))
    end
    it("creates a deck of cards that contain the contents of an array of cards") do

    end
  end
  context('#default_deck') do
    it("Returns an unshuffled array of all 52 standard cards") do
      default_deck = Deck.default_deck
      expect(default_deck.length).to(eq(52))
      default_deck.each {|item| expect(item.is_a?(Card)).to eq true}
    end
  end

  context('.shuffle') do
    before(:each) do
      test_deck.shuffle
    end
    let(:unmatched_card) {false}
    let(:second_deck) {Deck.new}
    
    it("shuffles itself") do
      test_deck_suits = test_deck.cards.map(&:suit)
      test_deck_ranks = test_deck.cards.map(&:rank)
      expect(test_deck_suits == second_deck.cards.map(&:suit)).to(eq(false))
      expect(test_deck_ranks == second_deck.cards.map(&:rank)).to(eq(false))
    end
  end

  context('.draw_card') do
    it("removes a card from the top of the deck and returns it") do
      passed_cards = [Card.new(rank:"4", suit:"H"), Card.new(rank:"7", suit:"C")]
      rigged_deck = Deck.new(passed_cards)
      drawn_card = rigged_deck.draw_card
      expect(drawn_card.suit != rigged_deck.cards[0].suit).to(eq(true))
      expect(drawn_card.rank != rigged_deck.cards[0].rank).to(eq(true))
    end
  end
end
