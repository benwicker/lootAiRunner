require './enums.rb'

class Card
  attr_accessor :owner
  attr_accessor :type
  attr_accessor :value
  attr_accessor :color
  
  def initialize(type, value, color)
    @owner = nil
    @type = type
    @value = value
    @color = color
  end

  def as_string
    "#{@type}#{@value}#{@color}"
  end
end

def setup_game_deck  
  deck = []
  deck += Array.new(5, Card.new(CardType::MERCHANT, 2, nil))
  deck += Array.new(6, Card.new(CardType::MERCHANT, 3, nil))
  deck += Array.new(5, Card.new(CardType::MERCHANT, 4, nil))
  deck += Array.new(5, Card.new(CardType::MERCHANT, 5, nil))
  deck += Array.new(2, Card.new(CardType::MERCHANT, 6, nil))
  deck += Array.new(1, Card.new(CardType::MERCHANT, 7, nil))
  deck += Array.new(1, Card.new(CardType::MERCHANT, 8, nil))

  deck.push(Card.new(CardType::CAPTAIN, nil, nil))

  Color::ALL.each do |color|
    deck.push(Card.new(CardType::CAPTAIN, nil, color))
    deck += Array.new(2, Card.new(CardType::PIRATE, 1, color))
    deck += Array.new(4, Card.new(CardType::PIRATE, 2, color))
    deck += Array.new(4, Card.new(CardType::PIRATE, 3, color))
    deck += Array.new(2, Card.new(CardType::PIRATE, 4, color))
  end

  deck.shuffle!
end