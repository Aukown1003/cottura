FactoryBot.define do
  #材料のダミーデータ
  factory :recipe_ingredient do
    name { Faker::Lorem.words(number: 3) }
    quantity { Faker::Number.number(digits: 10) }
    unit { association :unit }
  end
end