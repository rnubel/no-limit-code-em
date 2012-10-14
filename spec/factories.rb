FactoryGirl.define do
  factory :tournament do
    open  true
  end

  factory :player do
    key             "asdfasdfasdfsdf"
    sequence(:name) { |n| "Bill#{n}" }

    trait :registered do
      after_create do |p|
        p.registrations << FactoryGirl.create(:registration, :player => p)
      end
    end
  end

  factory :registration do
    player
    tournament
    purse 100
    current_stack 100
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
