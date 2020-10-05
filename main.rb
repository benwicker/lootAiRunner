require './game.rb'

STDOUT.sync = true
puts 'starting program'
puts 'how many players?'
num_players = gets.chomp.to_i

puts 'initialize game'
game = Game.new(num_players)
current_player = 0
round = 0

puts 'play game'
while !game.game_over?
  if (current_player == 0)
    round += 1
    puts "start round #{round}"
  end

  puts "player #{current_player}'s turn'"

  game.evaluate_encounters(current_player)
  game.perform_turn(current_player)

  current_player += 1
  current_player = current_player % num_players

  # puts 'press enter to continue...'
  # gets.chomp()
end

puts 'game over'