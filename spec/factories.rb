FactoryGirl.define do
  factory :tournament do
    game_type 'draw_poker'
    open  true
  end

  factory :player do
    sequence(:key)  { |n| "asdfasdf#{n}asdf#{n+100}" }
    sequence(:name) { |n| "Bill#{n}" }

    trait :registered do
      tournament
    end
  end

  factory :table do
    tournament
  end

  factory :round do
    table
    ante 20
    playing true
  end

  factory :action do
    action "bet"
    amount 10
    player
    round
  end
end
