FactoryBot.define do
  #材料のダミーデータ
  factory :recipe_ingredient do
    recipe_id { association :recipe }
    unit_id { association :unit }
    name { Faker::Lorem.words(number: 3) }
    quantity { Faker::Number.number(digits: 3) }
  end
end