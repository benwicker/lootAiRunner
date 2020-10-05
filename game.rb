require './card.rb'
require './player.rb'
require './enums.rb'
require './encounter.rb'

class Game
  attr_accessor :players
  attr_accessor :draw_pile
  attr_accessor :encounters

  def initialize(num_players)
    @draw_pile = setup_game_deck()

    @players = []
    num_players.times do |i|
      new_player = Player.new("Player #{i}")
      new_player.hand = @draw_pile.shift(5)
      @players.push(new_player)
    end

    @encounters = []
    @current_encounter_id = 0
  end

  def game_over?
    if (@draw_pile.empty?)
      return @players.any? { |player| player.hand.empty? }
    end
    return false
  end

  def evaluate_encounters(player_index)
    # check encounters for resolution
  end

  def perform_turn(player_index)
    player_action = @players[player_index].perform_turn(nil)
    case player_action.type
    when PlayerActionType::DRAW
      draw(player_index)
    when PlayerActionType::PLAY_MERCHANT
      play_merchant(player_index, player_action.card)
    when PlayerActionType::PLAY_PIRATE
      play_pirate(player_index, player_action.card, player_action.encounter_id)
    end
  end
  
  def draw(player_index)
    top_card = @draw_pile.pop()
    top_card.owner = player_index
    puts "player #{player_index} drew #{top_card.as_string}"
    @players[player_index].hand.push(top_card)
  end

  def play_merchant(player_index, merchant_card)
    puts "player #{player_index} played #{merchant_card.as_string}"
    game.players[player_index].delete(merchant_card)
    @encounters.push(Encounter.new(@current_encounter_id, player_index, merchant_card))
    @current_encounter_id += 1
  end

  def play_pirate(player_index, pirate_card, encounter_id)
    enc = @encounters[encounter_id]
    my_plays = enc.plays.select { |p| p.owner == pirate_card.owner }


    if (my_plays.length > 0 })

    end

    if (enc.plays.any? { |p| p.color == pirate_card.color && p.owner != pirate_card.owner })
        #throw an exception if so
    end

    # check that the color isn't already in use
    # check if player has already played with a different color
  end
end