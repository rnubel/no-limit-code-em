FactoryGirl.define do
  factory :tournament do
    open  true
  end

  factory :player do
    sequence(:key)  { |n| "asdfasdf#{n}asdf#{n+100}" }
    sequence(:name) { |n| "Bill#{n}" }
    initial_stack 0

    trait :registered do
      tournament
      initial_stack 100
    end
  end

  factory :table do
    tournament
  end

  factory :round do
    table
    playing true
  end

  factory :action do
    action "bet"
    amount 10
    player
    round
  end
end
