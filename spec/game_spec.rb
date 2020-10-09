require './player.rb'
require './game.rb'
require './enums.rb'
require 'pry'

RSpec.describe Game do
    let!(:game) { Game.new(2) }
    
    it "instantiates a game" do
        expect(game.players.count).to eq(2)
        expect(game.draw_pile.count).to eq(68)
        expect(game.encounters.empty?).to be true
    end
    
    describe ".game_over?" do
        context "when draw pile is empty" do
            before do
                game.draw_pile = []
            end

            it "is game over if all player hands are empty" do
                game.players.each { |p| p.hand = [] }
                
                expect(game.game_over?).to be true
            end

            it "is game over if any players hand is empty" do
                game.players.first.hand = []

                expect(game.players.last.hand).not_to be_empty
                expect(game.game_over?).to be true
            end

            it "is not game over if all players have cards in hand" do
                expect(game.game_over?).to be false
            end
        end

        context "when draw pile is not empty" do
            it "is not game over even if a player has no cards" do
                game.players.first.hand = []

                expect(game.game_over?).to be false
            end
        end
    end

    describe ".draw" do
        context "when draw pile is empty" do
            before do
                game.draw_pile = []
            end

            it "raises an error" do
                expect{ game.draw(0) }.to raise_error("draw pile is empty")
            end
        end

        context "when draw pile has cards in it" do
            it "it removes the top card from the deck and adds it to the players hand" do
                card = build(:merchant)
                game.draw_pile.push(build(:merchant, :value => 3))
                game.draw_pile.push(card)
                current_count = game.draw_pile.count
                
                game.draw(0)

                expect(game.players[0].hand.count).to eq(6)
                expect(game.players[0].hand.last).to eq(card)
                expect(game.players[0].hand.last.owner).to eq(0)
                expect(game.draw_pile.last).not_to eq(card)
                expect(game.draw_pile.count).to eq(current_count - 1)
            end
        end
    end

    describe ".play_pirate" do
        let(:pirate_card) { build(:pirate, :owner => 0) }
        
        before do
            game.players[0].hand = []
            game.players[0].hand.push(pirate_card)
        end

        context "with no encounters" do
            it "raises an error if encounter id is not nil" do
                expect{ game.play_pirate(0, game.players[0].hand.last, 0) }.to raise_error("encounter does not exist")
            end

            it "discards the card if encounter id is nil" do
                game.play_pirate(0, game.players[0].hand.last, nil)

                expect(game.players[0].hand).to be_empty
            end
        end

        context "with encounters" do
            let(:encounter) { build(:encounter) }
            let(:p0_card) { build(:pirate, :owner => 0) }
            let(:p1_card) { build(:pirate, :owner => 1) }
            
            before do
                game.encounters.push(encounter)
            end

            context "the current player hasn't played on the encounter" do
                it "raises an exception if that color has already been played on the encounter" do
                    game.encounters[0].plays.push(p0_card)

                    expect { game.play_pirate(1, p1_card, 0) }.to raise_error("color already played by another player")
                end

                context "adds the card to the encounter and removes it from the player's hand" do
                    before do
                        game.players[1].hand = []
                        game.players[1].hand.push(p1_card)
                    end
                    
                    context "when there are a no captains" do
                        it "and makes the player the current winner when they have the most ships" do
                            game.play_pirate(1, game.players[1].hand.last, 0)
        
                            expect(game.players[1].hand).to be_empty
                            expect(game.encounters[0].plays[0]).to eq(p1_card)
                            expect(game.encounters[0].current_winner).to eq(1)
                            expect(game.encounters[0].current_max).to eq(3)
                        end
    
                        it "and does not make the player the current winner if they don't have the most ships" do
                            game.encounters[0].current_winner = 0
                            game.encounters[0].current_max = 4
                            game.play_pirate(1, game.players[1].hand.last, 0)
        
                            expect(game.players[1].hand).to be_empty
                            expect(game.encounters[0].plays[0]).to eq(p1_card)
                            expect(game.encounters[0].current_winner).to eq(0)
                            expect(game.encounters[0].current_max).to eq(4)
                        end    
    
                        it "sets the current winner to nil if the player ships count matches the current max" do
                            game.players[1].hand.last.color = Color::GREEN
                            game.encounters[0].plays.push(p0_card)
                            game.encounters[0].current_max = p0_card.value
                            game.play_pirate(1, game.players[1].hand.last, 0)

                            expect(game.players[1].hand).to be_empty
                            expect(game.encounters[0].plays[1]).to eq(p1_card)
                            expect(game.encounters[0].current_winner).to eq(nil)
                            expect(game.encounters[0].current_max).to eq(3)
                        end
                    end
                end
            end

            context "the current player has played on the encounter" do
                it "raises an exception if the player has already played a different color" do
                    game.players[0].hand = []
                    game.players[0].hand.push(build(:pirate, :owner => 0, :color => Color::BLUE))
                    game.players[0].hand.push(build(:pirate, :owner => 0, :color => Color::GREEN))

                    game.play_pirate(0, game.players[0].hand.last, 0)
                    
                    expect { game.play_pirate(0, game.players[0].hand.last, 0) }.to raise_error("already played on this enocunter with a different color")
                end
            end
        end

        describe "captains tests" do
            it "raises an error when the admiral is played on an encounter owned by another player" do
                encounter = build(:encounter, :played_by => 1)
                game.encounters.push(encounter)
                game.players[0].hand = []
                game.players[0].hand.push(build(:captain))

                expect { game.play_pirate(0, game.players[0].hand.last, 0) }.to raise_error("admiral played on invalid encounter")
            end

            it "works like a captain when played on owned encounters" do
                encounter = build(:encounter, :played_by => 0)
                game.encounters.push(encounter)
                game.players[0].hand = []
                game.players[0].hand.push(build(:captain))

                game.play_pirate(0, game.players[0].hand.last, 0)

                expect(game.encounters[0].current_winner).to eq(0)
                expect(game.encounters[0].current_max).to eq("c")
                expect(game.players[0].hand).to be_empty
            end
        end
    end

    describe ".evaluate_encounters" do
        let(:encounter) { build(:encounter) }
        let(:merchant_ship) { encounter.merchant_ship }

        before do
            game.encounters.push(encounter)
        end

        it "evaluates properly when current winners turn" do
            game.evaluate_encounters(0)
            
            expect(game.encounters).to be_empty
            expect(game.players[0].captured_ships[0]).to eq(merchant_ship)
        end

        it "evaluates properly when not current winner's turn" do
            game.evaluate_encounters(1)
            
            expect(game.encounters.count).to eq(1)
            expect(game.players[0].captured_ships).to be_empty
        end
    end
end