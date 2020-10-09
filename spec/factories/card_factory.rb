require './card.rb'
require './enums.rb'

FactoryBot.define do
    factory :merchant, class: "Card" do
        initialize_with { new(CardType::MERCHANT, 2, Color::BLUE) }
    end

    factory :pirate, class: "Card" do
        initialize_with { new(CardType::PIRATE, 3, Color::BLUE)}
    end

    factory :captain, class: "Card" do
        initialize_with { Card.new(CardType::CAPTAIN, nil, nil)}
    end
end