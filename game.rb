require './card.rb'
require './player.rb'
require './enums.rb'
require './encounter.rb'

class Game
  attr_accessor :players
  attr_accessor :draw_pile
  attr_accessor :encounters

  def initialize(num_players)
    @draw_pile = draw_pile || setup_game_deck()

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
    resolve_indexes = []

    @encounters.each_with_index do |enc, index|
      if enc.current_winner == player_index
        @players[player_index].captured_ships.push(enc.merchant_ship)
        resolve_indexes.push(index)
      end
    end

    resolve_indexes.each { |i| @encounters.delete_at(i) }
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
    raise "draw pile is empty" if @draw_pile.empty?

    top_card = @draw_pile.pop()
    top_card.owner = player_index
    @players[player_index].hand.push(top_card)
  end

  def play_merchant(player_index, merchant_card)
    game.players[player_index].delete(merchant_card)
    @encounters.push(Encounter.new(@current_encounter_id, player_index, merchant_card))
    @current_encounter_id += 1
  end

  def play_pirate(player_index, pirate_card, encounter_id)   
    if encounter_id == nil 
      @players[player_index].hand.delete(pirate_card)
      return
    end

    enc = @encounters.find {|e| e.id == encounter_id }

    raise "encounter does not exist" if enc.nil?
    raise "color already played by another player" if enc.plays.any? { |p| p.owner != player_index && p.color == pirate_card.color }
    raise "already played on this enocunter with a different color" if enc.plays.any? { |p| p.owner == player_index && p.color != pirate_card.color && pirate_card.color != nil }

    enc.plays.push(pirate_card)
    @players[player_index].hand.delete(pirate_card)

    if pirate_card.type == CardType::CAPTAIN
      raise "admiral played on invalid encounter" if pirate_card.color == nil && enc.played_by != player_index

      enc.current_winner = player_index
      enc.current_max = "c"
    else
      return if enc.current_max == "c"
      current_player_value = enc.plays.filter {|p| p.owner == player_index}.sum {|p| p.value }

      if current_player_value > enc.current_max
        enc.current_winner = player_index
        enc.current_max = current_player_value
      elsif current_player_value == enc.current_max
        enc.current_winner = nil
      end  
    end
  end
end