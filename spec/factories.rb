FactoryGirl.define do
  factory :tournament do
    open  true
  end

  factory :player do
    key             "asdfasdfasdfsdf"
    sequence(:name) { |n| "Bill#{n}" }
  end

  factory :table do
    tournament
  end

  factory :round do
    table
  end
end
