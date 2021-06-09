require_relative '../lib/player'
describe 'Player' do
  let(:player) {Player.new}
  context('.initialize') do
    it("doesn't have any cards when created") do
      expect(player.hand).to(eq([]))
    end
  end
  context('.add_card_to_hand') do
    it("adds a card to the player's hand") do
      test_card = Card.new(rank:"7", suit:"H")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([test_card]))
    end
    it("can add multiple cards to the player's hand") do
      test_cards = [Card.new(rank:"9", suit:"C"), Card.new(rank:"K", suit:"S")]
      player.add_card_to_hand(test_cards)
      expect(player.hand).to(eq(test_cards))
    end
    it("does not just replace the player's hand") do
      player.add_card_to_hand(Card.new(rank:"9", suit:"D"))
      test_card = Card.new(rank:"J", suit:"C")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([Card.new(rank: "9", suit: "D"), test_card]))
    end
  end
end
