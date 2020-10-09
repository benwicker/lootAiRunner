class Encounter
  attr_accessor :id
  attr_accessor :played_by
  attr_accessor :merchant_ship
  attr_accessor :plays
  attr_accessor :current_winner
  attr_accessor :current_max

  def initialize (id, played_by, merchant_ship)
    @id = id
    @current_winner = played_by
    @current_max = 0
    @played_by = played_by
    @merchant_ship = merchant_ship
    @plays = []
  end
end