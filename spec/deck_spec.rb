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
end
