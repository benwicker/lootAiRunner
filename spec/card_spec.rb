require './card.rb'
require './enums.rb'

RSpec.describe Card do
    it "instantiates a card" do
        card = Card.new(CardType::MERCHANT, 2, nil)

        expect(card.owner).to eq(nil)
        expect(card.type).to eq(CardType::MERCHANT)
        expect(card.value).to eq(2)
        expect(card.color).to eq(nil)
    end
end