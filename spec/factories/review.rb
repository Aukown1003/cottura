FactoryBot.define do
  # レビューのダミーデータ
  factory :review do
    user_id { association :user }
    recipe_id { association :recipe }
    content { Faker::Lorem.words(number: 20) }
    score { Faker::Number.between(from: 1, to: 5) }
  end
end