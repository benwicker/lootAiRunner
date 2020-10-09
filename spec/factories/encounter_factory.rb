require './card.rb'
require './encounter.rb'
require './enums.rb'

FactoryBot.define do
    factory :encounter do
        initialize_with { new(0, 0, build(:merchant)) }
    end
end