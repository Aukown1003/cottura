FactoryBot.define do
  # レシピモデルのダミーデータ
  factory :recipe do
    user_id { association :user }
    category_id { association :category }
    title { Faker::Lorem.characters(number: 20) }
    content { Faker::Lorem.characters(number: 20) }
    total_time { Faker::Number.number(digits: 3) }
    is_open { "true" }
    impressions_count { 0 }
    payload { nil }
    
    trait :with_recipe_ingredient do
      after(:build) do |recipe|
        ingredient = build(:recipe_ingredient, unit_id: unit.id)
        recipe.ingredients << ingredient
      end
    end
    
    trait :with_recipe_step do
      after(:build) do |recipe|
        step = build(:recipe_step)
        recipe.steps << step
      end
    end
    
  end
end