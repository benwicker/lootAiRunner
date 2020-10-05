require './enums.rb'

class Player
  attr_accessor :name
  attr_accessor :hand
  attr_accessor :points 

  def initialize (name)
    @name = name
    @hand = []
    @points = []
  end

  def perform_turn(game_state)
    # make call out to api here with game state
    # return action to be done
    PlayerAction.new(PlayerActionType::DRAW, nil, nil)
  end
end

class PlayerAction
  attr_accessor :type
  attr_accessor :card
  attr_accessor :encounter_id

  def initialize (type, card, encounter_id)
    @type = type
    @card = card
    @encounter_id = encounter_id
  end
end